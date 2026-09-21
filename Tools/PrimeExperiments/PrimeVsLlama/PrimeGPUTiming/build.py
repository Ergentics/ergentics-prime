#!/usr/bin/env python3
"""Compile this main against retained Release library objects. Never run inference."""
from pathlib import Path
import hashlib, json, os, shlex, shutil, signal, subprocess, sys, time

here = Path(__file__).resolve().parent
upstream = Path('/Users/ergentics/pmhnp-companion-ergentics/prime-runtime')
cache = upstream / '.build/arm64-apple-macosx/release'
build_name = sys.argv[1] if len(sys.argv) == 2 else 'build01'
assert len(sys.argv) <= 2 and build_name in ('build01', 'build02', 'build03', 'build04')
output = here / build_name
output.mkdir(mode=0o700)
(output / 'module-cache').mkdir(mode=0o700)

def binding(path):
    data = path.read_bytes()
    return {'path': str(path), 'byteCount': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def save(name, value):
    (output / name).write_text(json.dumps(value, indent=2) + '\n')

description = json.loads((cache / 'description.json').read_bytes())
command = description['swiftCommands']['C.PrimeNativeLanguageSwiftCanary-arm64-apple-macosx-release.module']
swiftc = command['executable']
objects_source = cache / 'PrimeNativeLanguageSwiftCanary.product/Objects.LinkFileList'
objects = shlex.split(objects_source.read_text())
old_main = str(cache / 'PrimeNativeLanguageSwiftCanary.build/main.swift.o')
assert objects.count(old_main) == 1
objects.remove(old_main)
assert len(objects) == 552 and all(Path(p).is_file() for p in objects)
allowed_modules = set(description['targetDependencyMap']['MLXLLM']) | {'MLXLLM'}
excluded_unused = [p for p in objects if Path(p).relative_to(cache).parts[0].removesuffix('.build') not in allowed_modules]
objects = [p for p in objects if p not in excluded_unused]
assert len(objects) == 441
response = output / 'retained-objects.rsp'
response.write_text('\n'.join(shlex.quote(p) for p in objects) + '\n')

flags = command['otherArguments']
sdk = flags[flags.index('-sdk') + 1]
target = flags[flags.index('-target') + 1]
assert target == 'arm64-apple-macosx14.0'
numerics = upstream / '.build/checkouts/swift-numerics/Sources/_NumericsShims/include'
cmlx = upstream / '.build/checkouts/mlx-swift/Source/Cmlx/include'
task_root = here.parents[2]
archived = task_root / 'outputs/Prime-Experiment-Builds/0009-prime-domain-feedback-runtime/Source'
guest_root = task_root / 'work/prime-domain-vcpu-2026-09-08/Guest'
admission_root = archived / 'Admission'
guest_receipt = json.loads((guest_root / 'build01/build-result.json').read_bytes())
assert guest_receipt['abiVersion'] == 2
for pin in guest_receipt['sourceFiles'] + [guest_receipt['bridgeObject'], guest_receipt['image'], guest_receipt['generatedHeader']]:
    assert binding(Path(pin['path'])) == pin, 'guest source/object binding changed'
for leaf in ['PrimeGuestBridge.h','PrimeGuestBridge.c','guest.S']:
    assert binding(archived / 'Guest' / leaf)['sha256'] == binding(guest_root / leaf)['sha256'], 'archived ABI2 source mismatch'
assert (here / 'main.before-measurement.swift').read_bytes() == (archived / 'Native/main.swift').read_bytes()
admission_object = output / 'PrimeInferenceAdmission.o'
admission_argv = ['/usr/bin/xcrun','clang','-target',target,'-isysroot',sdk,'-std=c11','-O2','-Wall','-Wextra','-Werror','-c',str(admission_root / 'PrimeInferenceAdmission.c'),'-o',str(admission_object)]
admission_compile = subprocess.run(admission_argv,capture_output=True,text=True,timeout=30)
save('admission-compile.json',{'argv':admission_argv,'exitCode':admission_compile.returncode,'stdout':admission_compile.stdout,'stderr':admission_compile.stderr})
assert admission_compile.returncode == 0, admission_compile.stderr
argv = [swiftc, str(here / 'main.swift'), '@' + str(response),
        str(guest_root / 'build01/PrimeGuestBridge.o'), str(admission_object),
        '-import-objc-header', str(here / 'Bridge.h'),
        '-o', str(output / 'PrimeVCPUInference'), '-I', str(cache / 'Modules'),
        '-module-name', 'PrimeVCPUInference', '-parse-as-library', '-swift-version', '5',
        '-target', target, '-sdk', sdk, '-O', '-whole-module-optimization',
        '-j2', '-num-threads', '2', '-module-cache-path', str(output / 'module-cache'),
        '-DSWIFT_PACKAGE', '-DSWIFT_MODULE_RESOURCE_BUNDLE_UNAVAILABLE',
        '-Xcc', '-fmodule-map-file=' + str(numerics / 'module.modulemap'),
        '-Xcc', '-I' + str(numerics),
        '-Xcc', '-fmodule-map-file=' + str(cmlx / 'module.modulemap'),
        '-Xcc', '-I' + str(cmlx),
        '-lc++', '-framework', 'Hypervisor', '-framework', 'Security', '-framework', 'CoreFoundation', '-framework', 'Foundation', '-framework', 'Metal', '-framework', 'Accelerate',
        '-Xlinker', '-dead_strip', '-Xlinker', '-no_warn_duplicate_libraries',
        '-Xlinker', '-rpath', '-Xlinker', '@loader_path']
environment = {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME': str(output), 'TMPDIR': str(output),
               'LANG': 'C', 'LC_ALL': 'C', 'GIT_ALLOW_PROTOCOL': 'file'}
source = upstream / 'Sources/PrimeNativeMetalSwiftCanary/main.swift'
original_slice = '\n'.join(source.read_text().splitlines()[173:220]) + '\n'
(output / 'original-architecture-and-logits.swift.txt').write_text(original_slice)
input_files = [here / 'main.swift', Path(__file__), source, cache / 'description.json',
               upstream / '.build/release.yaml', objects_source,
               numerics / 'module.modulemap', cmlx / 'module.modulemap']
input_files += [here / 'Bridge.h', guest_root / 'PrimeGuestBridge.h', guest_root / 'PrimeGuestBridge.c', guest_root / 'guest.S', guest_root / 'build01/PrimeGuestBridge.o', admission_root / 'PrimeInferenceAdmission.h', admission_root / 'PrimeInferenceAdmission.c', admission_object]
input_files += [here / 'main.before-measurement.swift', archived / 'Native/main.swift', archived / 'Guest/PrimeGuestBridge.h', archived / 'Guest/PrimeGuestBridge.c', archived / 'Guest/guest.S', guest_root / 'build01/build-result.json']
input_files += [upstream / '.build/checkouts/mlx-swift/Source/MLX' / leaf for leaf in ['Device.swift','Stream.swift','GPU.swift']]
input_files += sorted((cache / 'Modules').glob('*.swiftmodule'))
input_files += sorted(numerics.glob('*.h')) + sorted(cmlx.glob('*.h'))
input_files += [Path(p) for p in objects]
input_files += sorted(cache.glob('swift-version--*.txt'))
pins = [binding(p) for p in input_files]
metal_source = upstream / '.build/arm64-apple-macosx/debug/mlx.metallib'
shutil.copyfile(metal_source, output / 'mlx.metallib')
assert binding(metal_source)['sha256'] == binding(output / 'mlx.metallib')['sha256']
save('compile-inputs.json', {
    'scope': 'Timing-only derivative of retained0009 inference main, with explicit scopedGPU stream; linked against441 retained Release library objects in the recorded MLXLLM transitive dependency set. No dependency rebuild, package resolution or model invocation.',
    'files': pins, 'excludedMain': binding(Path(old_main)),
    'excludedUnusedRuntimeObjects': [binding(Path(p)) for p in excluded_unused],
    'compiler': binding(Path(swiftc).resolve()),
    'metallib': {'source': binding(metal_source), 'copy': binding(output / 'mlx.metallib'),
                'scope': 'Existing colocated MLX library from the same upstream .build checkout; copied, not recompiled.'},
    'runtimeDependencies': ['macOS system frameworks and Swift runtime', 'executable-adjacent mlx.metallib',
                            'caller-selected Prime10M checkpoint and input-only request'],
    'externalCompileDependencies': ['retained upstream Release objects/modules and C headers',
                                     'installed Xcode Swift compiler and macOS26.5 SDK']})
save('invocation.json', {'argv': argv, 'environment': environment, 'cwd': str(here),
                        'timeoutSeconds': 120, 'compilerThreads': 2, 'umask': '0077'})
(here / 'compile-command.txt').write_text(shlex.join(argv) + '\n')
os.umask(0o077)
started = time.monotonic_ns()
with (output / 'stdout.log').open('xb') as out, (output / 'stderr.log').open('xb') as err:
    child = subprocess.Popen(argv, cwd=here, env=environment, stdin=subprocess.DEVNULL,
                             stdout=out, stderr=err, start_new_session=True)
    timed_out = False
    signals = []
    try:
        code = child.wait(timeout=120)
    except subprocess.TimeoutExpired:
        timed_out = True
        try:
            os.killpg(child.pid, signal.SIGKILL)
            signals.append({'signal': 'SIGKILL', 'result': 'success', 'processGroup': child.pid})
        except ProcessLookupError:
            signals.append({'signal': 'SIGKILL', 'result': 'ESRCH', 'processGroup': child.pid})
        code = child.wait(timeout=10)
try:
    os.killpg(child.pid, 0)
    group_observation = 'present'
except ProcessLookupError:
    group_observation = 'absent_ESRCH'
except PermissionError:
    group_observation = 'unconfirmed_EPERM'
preserved = all(binding(Path(p['path'])) == p for p in pins)
result = {'status': 'PASS' if code == 0 and not timed_out and preserved else 'FAIL',
          'pid': child.pid, 'exitCode': code, 'exactDirectChildReaped': True,
          'elapsedNanoseconds': time.monotonic_ns() - started,
          'timedOut': timed_out, 'signals': signals, 'finalGroupObservation': group_observation,
          'capture': 'separate ordinary files; no pipe EOF claim',
          'stdout': binding(output / 'stdout.log'), 'stderr': binding(output / 'stderr.log'),
          'retainedInputsUnchanged': preserved, 'modelOrMetalExecution': False}
binary = output / 'PrimeVCPUInference'
if binary.exists():
    result['binary'] = binding(binary)
save('result.json', result)
print(json.dumps(result, indent=2))
raise SystemExit(0 if result['status'] == 'PASS' else 1)

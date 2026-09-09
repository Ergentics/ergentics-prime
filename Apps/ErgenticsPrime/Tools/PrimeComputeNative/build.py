#!/usr/bin/env python3
"""Compile two app-only services against retained objects; never sign or execute them."""
from pathlib import Path
import hashlib, json, os, shlex, shutil, signal, subprocess, sys, time

here = Path(__file__).resolve().parent
# Build assets are retained separately from this canonical source tree.
assets_path = here.parents[1] / 'BuildAssets.json'
assets = json.loads(assets_path.read_text())
if assets.get('schemaVersion') != 1:
    raise RuntimeError('Expected BuildAssets.json schemaVersion 1')
def asset_directory(key):
    value = assets.get(key)
    if not isinstance(value, str) or not Path(value).is_absolute() or not Path(value).is_dir():
        raise RuntimeError('Missing absolute build asset directory: ' + key)
    return Path(value)
task = asset_directory('taskRoot')
upstream = asset_directory('nativeRuntimeRoot')
cache = upstream / '.build/arm64-apple-macosx/release'
name = sys.argv[1] if len(sys.argv) == 2 else 'build01'
assert len(sys.argv) <= 2 and name in ('build01', 'build02', 'build03')
out = here / name
os.umask(0o077)
out.mkdir(mode=0o700)
(out / 'module-cache').mkdir(mode=0o700)

def binding(path):
    data = path.read_bytes()
    return {'path': str(path), 'byteCount': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def save(name, value):
    (out / name).write_text(json.dumps(value, indent=2) + '\n')

description = json.loads((cache / 'description.json').read_bytes())
command = description['swiftCommands']['C.PrimeNativeLanguageSwiftCanary-arm64-apple-macosx-release.module']
swiftc = command['executable']
flags = command['otherArguments']
sdk = flags[flags.index('-sdk') + 1]
target = flags[flags.index('-target') + 1]
assert target == 'arm64-apple-macosx14.0'
objects_source = cache / 'PrimeNativeLanguageSwiftCanary.product/Objects.LinkFileList'
objects = shlex.split(objects_source.read_text())
old_main = str(cache / 'PrimeNativeLanguageSwiftCanary.build/main.swift.o')
assert objects.count(old_main) == 1
objects.remove(old_main)
allowed = set(description['targetDependencyMap']['MLXLLM']) | {'MLXLLM'}
objects = [p for p in objects if Path(p).relative_to(cache).parts[0].removesuffix('.build') in allowed]
assert len(objects) == 441 and all(Path(p).is_file() for p in objects)
old_device = cache / 'Cmlx.build/mlx/mlx/backend/metal/device.cpp.o'
assert objects.count(str(old_device)) == 1
objects.remove(str(old_device))
new_device = out / 'resource-device.o'
rsp = out / 'retained-objects.rsp'
rsp.write_text('\n'.join(shlex.quote(p) for p in objects + [str(new_device)]) + '\n')
numerics = upstream / '.build/checkouts/swift-numerics/Sources/_NumericsShims/include'
cmlx = upstream / '.build/checkouts/mlx-swift/Source/Cmlx/include'

guest_model = task / 'work/prime-domain-vcpu-2026-09-08/Guest'
guest_geometry = task / 'work/prime-gpu-route-2026-09-08/GuestCompute'
guest_pins = []
for root, prefix, abi, local in [(guest_model, 'PrimeGuestBridge', 2, 'Model'),
                                (guest_geometry, 'PrimeGuestCompute', 1, 'Geometry')]:
    receipt = json.loads((root / 'build01/build-result.json').read_bytes())
    assert receipt['abiVersion'] == abi
    for pin in receipt['sourceFiles'] + [receipt['bridgeObject'], receipt['image'], receipt['generatedHeader']]:
        assert binding(Path(pin['path'])) == pin, 'retained guest source/object changed'
        guest_pins.append(pin)
    assert (here / local / (prefix + '.h')).read_bytes() == (root / (prefix + '.h')).read_bytes()

base_model = task / 'outputs/Prime-Experiment-Builds/0014-prime-model-gpu-timing/Source/main.swift'
base_geometry = task / 'work/prime-gpu-route-2026-09-08/NativeGPU'
assert (here / 'Reference/model-0014.swift').read_bytes() == base_model.read_bytes()
device_source = upstream / '.build/checkouts/mlx-swift/Source/Cmlx/mlx/mlx/backend/metal/device.cpp'
assert (here / 'Reference/device.before-resource-path.cpp').read_bytes() == device_source.read_bytes()
original_device = device_source.read_text()
modified_device = (here / 'Model/resource-device.cpp').read_text()
begin = 'MTL::Library* load_default_library(MTL::Device* device) {'
end = '\nMTL::Library* load_library('
assert original_device[:original_device.index(begin)] == modified_device[:modified_device.index(begin)]
assert original_device[original_device.index(end):] == modified_device[modified_device.index(end):]
assert (here / 'Reference/geometry-0013.swift').read_bytes() == (base_geometry / 'main.swift').read_bytes()
for leaf in ('MetalFieldEvaluator.swift', 'CPUReference.swift'):
    assert (here / 'Geometry' / leaf).read_bytes() == (base_geometry / leaf).read_bytes(), 'geometry math changed'
base_text = base_model.read_text()
model_text = (here / 'Model/main.swift').read_text()
def slice(text, begin, end): return text[text.index(begin):text.index(end, text.index(begin))]
for begin, end in [('private func makeModel()', 'private struct InputJob'),
                   ('    func predict(', '\nprivate func inferenceCallback')]:
    assert slice(base_text, begin, end) == slice(model_text, begin, end), 'model math or prediction changed'

files = [Path(__file__), here / 'Entitlements.plist', base_model, device_source, old_device, upstream / '.build/release.yaml']
for directory in ('Admission', 'Model', 'Geometry', 'Reference'):
    files += sorted(p for p in (here / directory).iterdir() if p.is_file())
files += [cache / 'description.json', objects_source, Path(swiftc).resolve()]
files += sorted((cache / 'Modules').glob('*.swiftmodule'))
files += sorted(numerics.glob('*.h')) + [numerics / 'module.modulemap']
files += sorted(cmlx.glob('*.h')) + [cmlx / 'module.modulemap']
files += [Path(p) for p in objects]
pins = [binding(p) for p in files] + guest_pins
save('compile-inputs.json', {'files': pins, 'excludedMain': binding(Path(old_main)),
    'scope': 'App admission/lifecycle adaptations only for model; dynamic one-request adapter around unchanged geometry kernel and guest ABI.',
    'dependencies': '440 retained Release MLXLLM transitive objects/modules plus one app-only default-metallib loader object; two source-bound guest objects; installed Xcode/SDK. No package resolution.',
    'replacedObject': binding(old_device), 'loaderChange': 'Only default-library resource path; no model/Metal math or external fallback change.',
    'modelMathUnchanged': True, 'geometryKernelUnchanged': True, 'guestABIsUnchanged': True})
environment = {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'TMPDIR': str(out), 'LANG': 'C', 'LC_ALL': 'C'}
steps = []

def compile_step(label, argv, deadline):
    save(label + '-invocation.json', {'argv': argv, 'environment': environment, 'cwd': str(here),
                                     'timeoutSeconds': deadline, 'maximumCompilerThreads': 2})
    began = time.monotonic_ns()
    timed = False
    with (out / (label + '-stdout.log')).open('xb') as stdout, (out / (label + '-stderr.log')).open('xb') as stderr:
        p = subprocess.Popen(argv, cwd=here, env=environment, stdin=subprocess.DEVNULL,
                             stdout=stdout, stderr=stderr, start_new_session=True)
        try:
            code = p.wait(timeout=deadline)
        except subprocess.TimeoutExpired:
            timed = True
            try: os.killpg(p.pid, signal.SIGKILL)
            except ProcessLookupError: pass
            code = p.wait(timeout=10)
    try:
        os.killpg(p.pid, 0)
        group = 'present'
    except ProcessLookupError: group = 'absent_ESRCH'
    except PermissionError: group = 'unconfirmed_EPERM'
    step = {'label': label, 'exitCode': code, 'processID': p.pid, 'exactDirectChildReaped': True,
            'elapsedNanoseconds': time.monotonic_ns() - began, 'timedOut': timed,
            'finalGroupObservation': group, 'capture': 'ordinary files; no pipe EOF claim',
            'stdout': binding(out / (label + '-stdout.log')), 'stderr': binding(out / (label + '-stderr.log'))}
    steps.append(step)
    save(label + '-result.json', step)
    if code != 0 or timed or group != 'absent_ESRCH':
        save('result.json', {'status': 'compile_failed', 'steps': steps, 'outputs': [], 'modelOrVMRuns': 0})
        raise SystemExit('Compile failed; exact attempt preserved at ' + str(out))

common = ['-parse-as-library', '-swift-version', '5', '-target', target, '-sdk', sdk,
          '-O', '-whole-module-optimization', '-j2', '-num-threads', '2',
          '-module-cache-path', str(out / 'module-cache'), '-framework', 'Hypervisor',
          '-framework', 'Security', '-framework', 'CoreFoundation', '-framework', 'Foundation', '-framework', 'Metal']
device_commands = [json.loads(line[len('    args: '):]) for line in (upstream / '.build/release.yaml').read_text().splitlines()
                   if line.startswith('    args: ') and str(device_source) in line]
assert len(device_commands) == 1
device_argv = device_commands[0]
assert device_argv[device_argv.index('-c') + 1] == str(device_source)
assert device_argv[device_argv.index('-o') + 1] == str(old_device)
device_argv[device_argv.index('-c') + 1] = str(here / 'Model/resource-device.cpp')
device_argv[device_argv.index('-o') + 1] = str(new_device)
device_argv[device_argv.index('-MF') + 1] = str(out / 'resource-device.d')
compile_step('resource-device', device_argv, 120)
pins.append(binding(new_device))
save('resource-device-binding.json', {'source': binding(here / 'Model/resource-device.cpp'),
     'object': binding(new_device), 'replaced': binding(old_device),
     'dependenciesFile': binding(out / 'resource-device.d'),
     'scope': 'Original compile arguments with only input, output and dependency-file destinations changed.'})
for service in ('PrimeModelService', 'PrimeGeometryService'):
    identifier = 'com.ergentics.provenance.' + ('prime-model-service' if service == 'PrimeModelService' else 'prime-geometry-service')
    admission = out / (service + '-Admission.o')
    compile_step(service + '-admission', [str(Path(swiftc).with_name('clang')), '-target', target, '-isysroot', sdk,
        '-std=c11', '-O2', '-Wall', '-Wextra', '-Werror', '-DPRIME_SERVICE_IDENTIFIER="' + identifier + '"',
        '-c', str(here / 'Admission/PrimeInferenceAdmission.c'), '-o', str(admission)], 30)
    pins.append(binding(admission))
    if service == 'PrimeModelService':
        argv = [swiftc, str(here / 'Model/main.swift'), '@' + str(rsp), str(guest_model / 'build01/PrimeGuestBridge.o'), str(admission),
                '-import-objc-header', str(here / 'Model/Bridge.h'), '-I', str(cache / 'Modules'),
                '-module-name', service, '-DSWIFT_PACKAGE', '-DSWIFT_MODULE_RESOURCE_BUNDLE_UNAVAILABLE',
                '-Xcc', '-fmodule-map-file=' + str(numerics / 'module.modulemap'), '-Xcc', '-I' + str(numerics),
                '-Xcc', '-fmodule-map-file=' + str(cmlx / 'module.modulemap'), '-Xcc', '-I' + str(cmlx),
                '-lc++', '-framework', 'Accelerate', '-Xlinker', '-dead_strip', '-Xlinker', '-no_warn_duplicate_libraries',
                '-Xlinker', '-rpath', '-Xlinker', '@loader_path']
    else:
        argv = [swiftc, *[str(here / 'Geometry' / p) for p in ('main.swift', 'MetalFieldEvaluator.swift', 'CPUReference.swift')],
                str(guest_geometry / 'build01/PrimeGuestCompute.o'), str(admission),
                '-import-objc-header', str(here / 'Geometry/Bridge.h'), '-module-name', service]
    compile_step(service, argv + common + ['-o', str(out / service)], 120)

metal = task / 'outputs/Prime-Experiment-Builds/0014-prime-model-gpu-timing/Runtime/mlx.metallib'
shutil.copyfile(metal, out / 'mlx.metallib')
assert binding(metal)['sha256'] == binding(out / 'mlx.metallib')['sha256']
unchanged = all(binding(Path(p['path'])) == p for p in pins)
outputs = []
for name in ('PrimeModelService', 'PrimeGeometryService', 'mlx.metallib'):
    b = binding(out / name)
    outputs.append({'name': name, 'byteCount': b['byteCount'], 'sha256': b['sha256']})
receipt = {'status': 'completed' if unchanged else 'input_changed', 'steps': steps, 'outputs': outputs,
           'inputsUnchanged': unchanged, 'signingPerformed': False, 'modelOrVMRuns': 0,
           'metallibSource': binding(metal), 'scope': 'Compilation only. Signed sandbox app launch remains to be verified.'}
save('result.json', receipt)
print(json.dumps(receipt, indent=2))
assert unchanged

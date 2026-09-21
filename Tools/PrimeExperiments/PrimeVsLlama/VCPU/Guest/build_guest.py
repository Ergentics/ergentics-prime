#!/usr/bin/env python3
"""Compile fixed AArch64 bytes and a C bridge. No VM creation or guest execution."""
from pathlib import Path
import hashlib, json, os, shlex, signal, struct, subprocess, time

root = Path(__file__).resolve().parent
out = root / 'build01'
out.mkdir(mode=0o700)
sdk = Path('/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk')
clang = Path('/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang')
environment = {'PATH': '/usr/bin:/bin:/usr/sbin:/sbin', 'HOME': str(out), 'TMPDIR': str(out), 'LANG': 'C', 'LC_ALL': 'C'}
commands = []

def binding(path):
    data = path.read_bytes()
    return {'path': str(path), 'byteCount': len(data), 'sha256': hashlib.sha256(data).hexdigest()}

def run(name, args):
    start = time.monotonic_ns()
    with (out / (name + '.stdout')).open('xb') as stdout, (out / (name + '.stderr')).open('xb') as stderr:
        child = subprocess.Popen(args, cwd=root, env=environment, stdin=subprocess.DEVNULL,
                                 stdout=stdout, stderr=stderr, start_new_session=True)
        timed_out = False
        try:
            status = child.wait(timeout=60)
        except subprocess.TimeoutExpired:
            timed_out = True
            try: os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError: pass
            status = child.wait(timeout=10)
    receipt = {'name': name, 'argv': args, 'pid': child.pid, 'exitCode': status,
               'exactDirectChildReaped': True, 'timedOut': timed_out,
               'elapsedNanoseconds': time.monotonic_ns() - start,
               'stdout': binding(out / (name + '.stdout')), 'stderr': binding(out / (name + '.stderr'))}
    commands.append(receipt)
    (out / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    if status != 0 or timed_out: raise RuntimeError(name + ' failed; inspect preserved compiler output')

os.umask(0o077)
source_files = [root / p for p in ['PrimeGuestBridge.h', 'PrimeGuestBridge.c', 'guest.S', 'build_guest.py']]
before = [binding(p) for p in source_files]
base = [str(clang), '-target', 'arm64-apple-macosx14.0', '-isysroot', str(sdk)]
run('assemble', base + ['-c', str(root / 'guest.S'), '-o', str(out / 'guest.o')])
blob = (out / 'guest.o').read_bytes()
header = struct.unpack_from('<IiiIIIII', blob)
assert header[0] == 0xfeedfacf and header[1] == 0x0100000c and header[3] == 1
cursor = 32; text = None; symtab = None
for _ in range(header[4]):
    command, size = struct.unpack_from('<II', blob, cursor)
    assert size >= 8 and cursor + size <= 32 + header[5]
    if command == 0x19:
        sections = struct.unpack_from('<I', blob, cursor + 64)[0]
        for i in range(sections):
            s = struct.unpack_from('<16s16sQQIIIIIIII', blob, cursor + 72 + i * 80)
            if s[0].rstrip(b'\0') == b'__text' and s[1].rstrip(b'\0') == b'__TEXT':
                assert text is None and s[7] == 0, 'guest text must have no relocation'
                text = {'address': s[2], 'size': s[3], 'offset': s[4]}
    elif command == 2:
        symtab = struct.unpack_from('<IIII', blob, cursor + 8)
    cursor += size
assert text and symtab and 0 < text['size'] <= 16384
symbols = {}
symoff, nsyms, stroff, strsize = symtab
strings = blob[stroff:stroff + strsize]
for i in range(nsyms):
    strx, kind, section, desc, value = struct.unpack_from('<IBBHQ', blob, symoff + i * 16)
    name = strings[strx:].split(b'\0', 1)[0].decode()
    if name.startswith('_epr_prime_guest_'):
        assert kind & 0x0e == 0x0e and section != 0
        symbols[name.removeprefix('_epr_prime_guest_')] = value - text['address']
assert symbols['start'] == 0 and symbols['end'] == text['size']
image = blob[text['offset']:text['offset'] + text['size']]
assert len(image) == text['size'] and len(image) % 4 == 0
for name, imm in [('infer', 0x41), ('complete', 0x42), ('invalid', 0x43)]:
    assert symbols[name + '_resume'] == symbols[name] + 4
    assert struct.unpack_from('<I', image, symbols[name])[0] == 0xd4000002 | (imm << 5)
(out / 'guest-image.bin').write_bytes(image)
lines = ['#ifndef EPR_PRIME_GUEST_IMAGE_H', '#define EPR_PRIME_GUEST_IMAGE_H', '#include <stdint.h>',
         '#define EPR_GUEST_IMAGE_SIZE ' + str(len(image)) + 'u']
for name, offset in sorted(symbols.items()): lines.append('#define EPR_GUEST_' + name.upper() + '_OFFSET ' + str(offset) + 'u')
lines += ['static const uint8_t epr_guest_image[EPR_GUEST_IMAGE_SIZE] = {']
for i in range(0, len(image), 16): lines.append('    ' + ', '.join(f'0x{x:02x}' for x in image[i:i+16]) + ',')
lines += ['};', '#endif', '']
(out / 'PrimeGuestImage.h').write_text('\n'.join(lines))
run('compile-c', base + ['-std=gnu11', '-O2', '-Wall', '-Wextra', '-Werror', '-I', str(out),
                        '-c', str(root / 'PrimeGuestBridge.c'), '-o', str(out / 'PrimeGuestBridge.o')])
assert before == [binding(p) for p in source_files]
sdk_headers = sdk / 'System/Library/Frameworks/Hypervisor.framework/Headers'
receipt = {'status': 'COMPILED_NOT_EXECUTED', 'sourceFiles': before, 'sourceFilesUnchanged': True,
           'commands': commands, 'image': binding(out / 'guest-image.bin'), 'symbols': symbols,
           'generatedHeader': binding(out / 'PrimeGuestImage.h'), 'bridgeObject': binding(out / 'PrimeGuestBridge.o'),
           'compiler': binding(clang.resolve()), 'sdkHypervisorHeaders': [binding(p) for p in sorted(sdk_headers.glob('*.h'))],
           'modelRuns': 0, 'guestRuns': 0, 'vmCreates': 0,
           'derivation': 'Mach-O64 __TEXT,__text bytes; no relocation; exported fixed labels and three HVC opcodes verified. No objcopy or linker needed.',
           'linkInstruction': 'Link PrimeGuestBridge.o with the Swift host and -framework Hypervisor. Import PrimeGuestBridge.h as its bridging header. Sign with com.apple.security.hypervisor entitlement.'}
(out / 'build-result.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({'status': receipt['status'], 'bridgeObject': receipt['bridgeObject'], 'image': receipt['image'], 'symbols': symbols}, indent=2))

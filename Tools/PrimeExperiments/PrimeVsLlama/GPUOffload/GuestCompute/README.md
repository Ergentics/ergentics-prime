# Fixed 2D geometry compute transport

`build01/PrimeGuestCompute.o` is a new arm64 macOS14 bridge using Apple's Hypervisor.framework. It reuses the verified VM/watchdog/cleanup implementation from the earlier ABI 2 experiment without modifying that source. The build creates no VM, runs no guest, and imports no Metal, MLX or model implementation. The Swift caller supplies the actual bounded geometry compute callback and records Metal timing and numerical checks separately.

Import `PrimeGuestCompute.h`, link the object with `-framework Hypervisor`, and use the normal signed helper admission before calling:

```c
int32_t epr_prime_compute_run(const EPRPrimeComputeInput *input,
    EPRPrimeComputeCallback callback, void *context, EPRPrimeComputeResult *result);
```

The input contains 1–200 interleaved XY points, 1–64 interleaved XY/weight nodes, and a finite positive F32 sigma. All active coordinates and weights must be finite. Reserved fields and unused array slots must contain zero bits. These checks occur before VM creation. No text, model input, teacher labels, caller-provided guest code or arbitrary operation selector is accepted.

The sole operation is a typed 2D potential/gradient computation. The callback receives pointers to the actual stopped guest input and its dedicated reply area. It fills exactly `3*pointCount` finite F32 values: potentials first, followed by interleaved gradient XY values. The bridge retains the actual input/reply, rejects a wrong count, non-finite value or nonzero reserved/unused slot, and checks that every byte outside the reply stayed unchanged before resuming the guest. A rejected NaN reply remains available as raw float bits in `observedReply`; callers must serialize those bits rather than attempting JSON NaN encoding.

The immutable 152-byte guest issues request HVC`0x51`, waits for the host reply, reads every returned UInt32 float bit pattern in order, and commits its own read count and checksum before completion HVC`0x52`. The checksum starts at `0xcbf29ce484222325`; each UInt32 word is XORed into the checksum, then multiplied by `0x100000001b3` modulo2^64. This is a word-wise transport checksum, not the byte-wise FNV variant. The host independently computes the same value but never writes the guest's completion count or checksum.

Guest code starts at IPA`0x10000000`; data starts at IPA`0x10004000`. The 64-byte control header precedes the exact 2384-byte input at offset64. The 2408-byte reply occupies a separate area at offset4096. Remaining data bytes are fixed guard padding. Each host allocation has an inaccessible 16KiB guard page on both sides. Host code backing is READ-only, mapped to the guest READ|EXEC; data is READ|WRITE. Host protections, complete code bytes and the full expected data page are checked at admission, both HVC exits and after callback return. Instruction cache invalidation follows the initial code copy.

Only the fixed request instruction/resume offsets44/48 and completion offsets144/148 are admitted. Actual PC, syndrome, registers, page-validation observations, input/reply values, checksum and lifecycle return codes are retained. The guest count must equal the exact expected `3*pointCount`; completion requires identical input, reply and guard bytes plus the guest-owned read count/checksum. A checksum match verifies transport; the Swift host's separate reference comparison determines numerical correctness. This is a real guest-to-host compute request, not a virtual GPU device, guest Metal driver, or GPU model execution.

One owning thread creates and operates the VM/vCPU, invokes the callback, and performs cleanup. The unchanged 10-second watchdog only calls `hv_vcpus_exit`; the owner joins it before vCPU destruction, unmapping, VM destruction and freeing memory. A join failure is fail-stop78, and uncertain cleanup blocks subsequent bridge calls. A synchronous callback cannot be forcibly interrupted by this thread watchdog; the caller's separate outer process deadline remains required. `INT32_MIN` marks unattempted lifecycle operations. There are at most two vCPU entries and one callback.

`python3 build_guest.py` uses two sequential, bounded compiler calls and refuses an existing build01. It extracts relocation-free Mach-O `__TEXT,__text`, verifies fixed exported offsets and both HVC encodings, generates `PrimeComputeImage.h`, and compiles C with `-Wall -Wextra -Werror`. `build01/build-result.json` binds every current source, compiler, SDK Hypervisor header, generated image/header and object. It also records the predecessor source/object hashes and verifies they remain unchanged. Root performs signing and any subsequent live VM/Metal invocation.

# Fixed Prime inference guest bridge

`build01/PrimeGuestBridge.o` is compiled for arm64 macOS14 using the installed macOS26.5 SDK. Link it into the dedicated Swift experiment helper with `-framework Hypervisor` and import `PrimeGuestBridge.h`. The helper needs Apple's `com.apple.security.hypervisor` entitlement. Existing application and fixed-guest source is untouched. The build does not create a VM or run a guest/model.

The synchronous API is:

```c
int32_t epr_prime_guest_run(const EPRPrimeGuestJob *jobs, uint32_t count,
    uint32_t allowedMin, EPRPrimeGuestInferenceCallback callback, void *context,
    EPRPrimeGuestResult *result);
```

There are 1–5 jobs, each with 1–64 input IDs in `0..<16384`. Unused input array slots must be zero. `priorPredictionOffset` is −1 or a valid input slot; the first job must use −1. `allowedMin` is exactly16 or64, identifying eight assigned value symbols. The callback returns0 only after writing its unrestricted prediction in `0..<16384`; any callback error aborts this run. Model loading, actual MLX inference, logits persistence and hashes belong to the Swift host. This bridge contains no weights, targets, correct answers, text conversion, optimizer or training operation.

The immutable guest starts at IPA`0x10000000`, reads its job table at IPA`0x10004000`, and owns the step loop. Before a continuation it checks that its previous prediction is one of the eight assigned symbols, inserts that prediction into the next input slot, and exits through HVC`0x41`. The host verifies the exact active input page and registers against the original jobs and previously returned predictions, invokes the callback on the owning thread, and returns the actual prediction through X0. The guest stores it and increments its own completed count before the next exit. After the last job it issues completion HVC`0x42`. Invalid feedback issues HVC`0x43` before inserting a value or requesting the next inference.

Guest completion is not a correctness claim. A final out-of-domain prediction can complete the guest when no subsequent job needs feedback; it remains the actual neural output and must be judged by the separate scorer. `completedCount` and `predictions` represent stores observed after guest execution, not merely successful host callbacks. `observedJobs` records callback inputs; request/return/callback/commit counters distinguish incomplete prefixes.

Only two guest pages are mapped: code with guest READ|EXECUTE rights and data with guest READ|WRITE rights. The host code backing is READ-only; it is never executed as host instructions, so no JIT entitlement is required. Each host backing has an inaccessible 16KiB guard page on either side. The bridge checks actual host region protections with `mach_vm_region`, every fixed code byte, the exact expected data state and its padding at admission and each HVC boundary. It invalidates the instruction cache after copying guest bytes. No caller-supplied guest code, mapping, entry point or HVC service is accepted.

Exit evidence retains actual reason, syndrome, addresses, PC, CPSR, SCTLR and relevant general registers. The only admitted HVC syndromes are `0x5a000041`, `0x5a000042` and `0x5a000043`. PC must be at that specific fixed HVC instruction or its immediately following fixed label; the actual observed PC is recorded. Inference return explicitly selects that one resume label, avoiding a blind PC increment. Other exits, unexpected memory/register state, callback errors or more than `jobCount+1` entries fail.

All owning Hypervisor operations and callbacks remain on the calling thread. A joined pthread watchdog has a fixed10-second deadline and bounded wake count; its sole Hypervisor operation is the documented thread-safe `hv_vcpus_exit`. It cannot destroy resources. The owner joins it before destroying the vCPU, unmapping guest pages, destroying the VM and freeing host backing. A join failure terminates the helper with78 rather than returning while a watcher might still reference its stack/vCPU. Failed HV cleanup returns failure and permanently blocks later calls through this bridge; backing is retained if a live mapping cannot be ruled out. Calls cannot overlap.

The watchdog can interrupt guest execution, not an arbitrary synchronous Swift callback. The Swift adapter and its outer process owner must enforce their own finite callback/process deadline. Incomplete callback/guest/cleanup outcomes remain failures, even when earlier logits exist. `INT32_MIN` marks unattempted lifecycle fields. Build success is separate from actual signed Hypervisor/Metal execution, which the root task coordinates and records.

`build_guest.py` uses two sequential bounded compiler entries, never package resolution. It assembles `guest.S`, extracts the exact Mach-O `__TEXT,__text` bytes, rejects relocations, and verifies exported label offsets plus all three HVC instruction encodings. It emits a fixed C image header and compiles the bridge with `-Wall -Wextra -Werror`. `build01/build-result.json` retains source/compiler/SDK-header hashes, raw compiler streams, the 200-byte image binding and object binding. Re-running into an existing build01 is refused; preserve it before preparing a separately named successor.

# Prime runtime integration — paused for local delivery

The user chose to install verified Build 19 first, then iterate. Build 19 is the usable baseline. This Build 20 experiment is not installed or uploaded.

Implemented in this checkout: a Prime sidebar page, a signed app-owned native helper, explicit Check/Stop actions, cancellation and Quit ownership, a parent-exit watchdog, Xcode packaging of the pinned local MLX dependencies and freshly built Metal library, and bundled license notices. The 149 copied Prime implementation files remain unchanged.

The signed app builds. Actual app clicks launched the helper. The first click exposed a Swift actor-isolation crash in the parent watchdog; an explicit Sendable capture fixed that callback. The next live attempt reached the existing Prime Metal lease validator and failed with `PrimeMetalDeviceLeaseError.parentHasExtendedAttributes`. The latest build adds extended-attribute names to that diagnostic, but was not run before the user's delivery-first instruction.

No successful native GPU initialization, decoder forward pass, checkpoint load or generation is claimed. Six focused app adapter tests were added but have not been run. The Gate E 350-test checkpoint is separate, unchanged evidence.

Resume from the app integration: run the already-built diagnostic through the app, identify the lease directory's rejected attribute, and supply suitable app-owned storage while preserving the existing native checks. Then verify the live runtime, Stop/Quit and the focused tests. A compatible retained Native-300M V2 checkpoint is still needed for checkpoint loading and generation; older Llama-based canary files must not be silently substituted.

Development checkout: `work/prime-app-integration/repo` in the September 5 task workspace. Build products: `work/prime-app-integration/DerivedData/Build/Products/Release`. Logs and the retained watchdog crash report are beside that checkout. Use `-jobs 2` and focused tests; do not resume the expensive 350-test Debug fixture suite by default.

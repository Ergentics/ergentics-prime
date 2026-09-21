# Native Prime in the app

This local package links the existing Ergentics Prime implementation into the app-owned `ErgenticsPrimeRuntime` helper. Xcode builds the helper and Metal library together. Runtime work starts only from **Prime → Check native runtime**, runs off the app's main thread, and is bounded to 30 seconds. Stop and Quit cancel the owned child; the helper also exits if its parent disappears.

The current action calls `PrimeNativeDecoderRuntime.initializeCurrentProcess`. That method validates its launch environment, holds the existing Metal lease, checks the freshly built library against the bundled expectation, and evaluates the exact FP32 GPU probe. It does not allocate decoder weights or perform inference. Checkpoint loading and generation remain the next app integration work. Prime Git remains a separate snapshot viewer.

Source lineage:

| Component | Revision |
| --- | --- |
| Ergentics Prime core, decoder, checkpoint and maintained runtime | `05e81739cbe5a985809fb4b83ce3d8cadc48d301`; all 149 copied files unchanged |
| Ergentics MLX Swift fork | `d37885a278f1c37484a94d0f401a418735e66519` |
| Nested MLX core | `ce45c52505c8158ea48d2a54e8caae05efd86bfe` |
| Nested MLX C API | `0726ca922fc902c4c61ef9c27d94132be418e945` |
| Swift Numerics | `0c0290ff6b24942dadb83a929ffaaa1481df04a2` |

All dependencies are vendored from their existing local checkouts; building requires no package downloads. The new package manifest narrows the target graph to the runtime dependency closure. The vendored MLX manifest changes only its Swift Numerics dependency to the adjacent local path. Model and MLX implementation files remain unchanged. The helper and UI are new application adapters.

The app's resource seal covers the helper's Metal library and expectation. The native runtime retains its original distinction between a source-pinned exclusive loader candidate and independent observation of the loaded image. Prior Paravirtual-device evidence and Driver V2 gate results are preserved; this adapter does not close Gate E or establish a trained checkpoint.

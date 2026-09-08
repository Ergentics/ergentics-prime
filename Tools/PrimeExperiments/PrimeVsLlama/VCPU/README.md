# Prime vCPU inference integration

The native AArch64 guest controls model requests and inserts actual previous predictions into continuation inputs. Native/ contains Swift MLX inference, Guest/ the fixed guest and Hypervisor bridge, and Admission/ the dedicated signed-helper admission. The existing app/fixed-guest implementation is unchanged.

Run the saved suite from this directory with `/usr/bin/python3 Runtime/replay.py /absolute/new-output`. RUN-CONFIG.json points to the saved signed runtime0008 and Requests retains the exact original checkpoint paths. Model weights stay in the local durable builds. Raw results and executable are at:

/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-vCPU-02

For a fresh source build, run `python3 Guest/build_guest.py build01` followed by `python3 Native/build.py build01`. The native build reuses recorded local MLX dependency objects and the newly built Guest/build01 object. RecordedBuild folders preserve the actual source/compile records for the completed run. Signing requires the dedicated identifier/team and hypervisor-only entitlement documented in Admission/README.md. Never treat a newly built binary as a reviewed run without fresh execution.

The tracked results live under docs/experiments/2026-09-08-prime-vcpu. All720 jobs exactly match previous host logits and predictions. The next retained domain-policy suite needs two-source feedback and its original full-vocabulary continuation semantics; see that report's NEXT.md.

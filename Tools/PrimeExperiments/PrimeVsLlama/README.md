# Live Prime experiments

The current completed integration is [Domain](Domain/README.md): native Swift/Metal inference, real ARM vCPU control with two-source prediction feedback, three retained Prime domain-policy checkpoints, a same-input older Llama comparison, a1024-case valid-input generator follow-up, and geometry-app host Metal parity.

Runtime0009 and checkpoint builds0010–0012 are durable local artifacts. Raw model outputs are retained; scoring targets never replace predictions. These experiments use the existing Prime project and do not change the installed Provenance app.

Earlier completed experiment source remains in NativeSwift/ and [VCPU](VCPU/README.md). Their corresponding sealed builds and reports preserve original results. The current results, executable and replay entry point are:

/Users/ergentics/Documents/Codex/2026-09-05/build-11-is-archived-locally-users/outputs/Prime-Experiment-Builds/Prime-Domain-03/README.md

The code establishes inference and feedback behavior. It does not make the finite domain-policy checkpoint a prose chatbot, move model weights into a guest, or change formal gate authority.

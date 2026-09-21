# ABI 2 mechanism checks

`python3 build.py` compiles `build01/PrimeGuestABITwoChecks` against the already built ABI 2 Guest object and the exact admission object from Native/build01. It does not execute the binary, create a VM, load MLX, or invoke a model. Root signs the executable with the existing dedicated helper identity and Hypervisor entitlement before its serialized run. The binary accepts no arguments and has a 30-second process alarm.

Each check first calls the actual unchanged process admission function. Admission rejection exits77 before a bridge call; any unexpected fixture result exits1 before starting another VM. All VM checks require successful VM/vCPU setup, page/register/HVC validation, joined watchdog, exact cleanup statuses and no watchdog firing. The three invalid-input checks require no VM creation, run or callback.

The six fixed fixtures are:

1. Four jobs return fixture IDs17,19,22,20. Job3 names source jobs1 and2; its observed callback input must be exactly `[60,19,22,61]`. The guest commits all four values.
2. Two bindings name the same input offset: reject before VM creation.
3. A binding names its own job: reject before VM creation.
4. Job1 names forward job2: reject before VM creation.
5. Full-vocabulary policy `(0,16384)` carries fixture ID224 through a guest-owned insertion, then commits16383. ID224 is admitted as an ordinary vocabulary token; any domain meaning such as ABSTAIN belongs to the separate model scorer.
6. Under `(16,8)`, job1 returns19 and job2 returns47. Job3 inserts19 from source1, then rejects source2 before its next callback. The validated full-page state must retain first slot19 and second placeholder0; the invalid HVC identifies binding ordinal1, input offset2 and source job2. There are three callbacks/commits, four VM entries and no completion HVC.

JSONL retains requests, fixture values and observed inputs, admission observations, all numeric Guest result fields and per-check results. These callbacks are deliberate mechanism fixtures, never neural predictions or scientific evidence. Original Guest/Native source and prior experiment outputs are unchanged.

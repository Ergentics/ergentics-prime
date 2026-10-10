# Prime learning Worker

Disabled source for a bounded, hosted AI Gateway binding pilot. Worker `ergentics-prime-learning-dev`; Workflow `ergentics-prime-learning-pilot`. Source custody begins in the US Cloudflare Artifacts repository `ergentics-prime-us/ergentics-prime`; GitHub carries this selected secondary copy.

[worker.mjs](worker.mjs), [wrangler.jsonc](wrangler.jsonc) and [RUN-CONTRACT.json](RUN-CONTRACT.json) are exact copies of the pinned Cloudflare source. [SOURCE-ORIGIN.json](SOURCE-ORIGIN.json) records the source commit, paths, hashes and limits. This README and [HOSTED-PILOT.md](HOSTED-PILOT.md) are adapted for this GitHub folder.

All four activation gates are false. Public HTTP returns an empty 404; workers.dev, preview URLs and routes are disabled. No scheduled trigger is configured. This handoff makes no explicit deployment, inference or CI invocation; other installed-app/Cloudflare listeners remain NOT_ASSESSED as recorded in the connection plan. The package has not been built, deployed or run. Eleven response-projection fixtures and broader hosted acceptance cases remain NOT_RUN.

An authorized Cloudflare dashboard launch with empty parameters `{}` would call a fixed US Durable Object ledger, which reserves one irreversible inference allowance before the AI binding dispatch. The fixed request is a synthetic public-documentation question through `default / dynamic/ergentics_learning_v1`. Stored OpenAI BYOK remains in Cloudflare. No Prime/MLX corpus, Qwen base, training, arbitrary tool, R2 or Container activation is included.

## Access and evidence

The exact-copy contract's `authority.currentNativeGrant` records the historical pre-extension Account Read/Artifacts Write inventory. Later safe Wrangler metadata verified `offline_access`, `account:read`, `artifacts:write`, `workers_scripts:write`. That product-scoped grant does not enforce one named Worker or account and does not qualify every deployment endpoint.

No provider key, Gateway bearer, authorization code or manually supplied credential belongs in source, prompts or build variables; a later reviewed Cloudflare-held deployment grant remains separate. Account/resource/route identifiers in these files are public metadata; this package is not deidentified.

The ledger's US jurisdiction restricts that Durable Object. It does not establish US-only Worker, Workflow or provider processing. A response does not independently establish provider/model identity, current route graph, physical call count, billing or provider cancellation. Operator activation flags are attestations, not live configuration proof. All twelve source-review findings remain OPEN; source transfer closes none.

## Source connection

See [GITHUB-CONNECTION.md](../GITHUB-CONNECTION.md). This is a selected one-way source handoff, not an automatic mirror or a verified Cloudflare GitHub App/Builds connection. Original Prime history, source, license/notices and existing workflows remain in the parent tree.

Local source execution remains held for this review. Pinned Wrangler4.147.0 deployment still invokes local esbuild parsing and may execute submitted code through conditional Miniflare startup diagnostics. A later hosted build requires its own source connection, reviewed cloud-held deployment grant and explicit execution selection.

Official references: [AI binding](https://developers.cloudflare.com/ai-gateway/usage/worker-binding-methods/), [Workflows](https://developers.cloudflare.com/workflows/build/workers-api/), [US DO jurisdiction](https://developers.cloudflare.com/durable-objects/reference/data-location/), [Artifacts integration](https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/artifacts-integration/).

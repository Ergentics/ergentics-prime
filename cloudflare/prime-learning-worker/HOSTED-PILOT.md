# Hosted pilot contract

State: AUTHORED_NOT_EXECUTED_NOT_DEPLOYED. This GitHub document adapts the pinned Cloudflare review; [source origin](SOURCE-ORIGIN.json) binds the exact runtime/configuration/contract bytes.

## Fixed operation

Account `940705aeb10207356a9e0b2445bb06b6`; Worker `ergentics-prime-learning-dev`; Workflow `ergentics-prime-learning-pilot`; canonical attempt `PRIME-AI-BINDING-20261009-01`.

A later owner-selected Cloudflare dashboard launch with `{}` may enter one Workflow step with retry limit zero and a 45-second timeout. Dashboard account authorization does not independently identify the human owner. The step calls the fixed US SQLite DO. A one-shot DO alarm seals interrupted state only; it never calls AI. Public HTTP is empty404. No Cron or Workflow schedule is configured.

The DO consumes one binding invocation slot durably before dispatch and waits up to 30 seconds. Unknown, failed, interrupted, timed-out or malformed results remain consumed. A new Workflow instance cannot replenish the same ledger. Preserve the real namespace, class, jurisdiction, fixed object identity and spent record; recreating any of them to reset the allowance is not authorized. There is no exactly-once guarantee spanning the platform and provider.

The sole prompt is: “Does Cloudflare's Workers AI binding expose env.AI? Reply exactly YES or NO.” Request: max_tokens8, nonstreaming, Gateway `default`, route `dynamic/ergentics_learning_v1`, cache skip and content-log suppression requested. The accepted response text is at most64 UTF-8 bytes; this is not a wire, heap or cost bound. No response body or exception is persisted; safe receipt fields are projected.

## Gates before any provider call

Keep `PILOT_ENABLED`, `PILOT_ROUTE_POLICY_ATTESTED`, `PILOT_DEFAULT_ALIAS_ATTESTED` and `PILOT_FALLBACK_DISABLED_ATTESTED` at the exact string `false` during initial disabled deployment.

A later qualified disabled invocation runs eleven fixed response-projection fixtures with zero inference dispatches. Check the actual deployed source/version, AI binding, Workflow, SQLite migration, US DO jurisdiction, disabled public URLs/routes and absence of schedules. These fixtures and broader acceptance scenarios remain NOT_RUN.

Before any explicit activation, review the default Gateway's current graph/provider/model, zero configured retries, no alternate provider/model fallback, OpenAI provider key's `default` alias and Require Provider Credentials. Flags merely attest to that review. Route names are mutable; this package cannot atomically pin the deployed graph. The Gateway name and provider-key alias are different settings.

A positive answer only qualifies the bounded observed output. Provider/model identity, physical calls, billing and broader data locality require separate evidence. A controller deadline does not prove upstream cancellation.

## Deployment selection remains separate

[Connection plan](../GITHUB-CONNECTION.md) distinguishes repository access from build triggers. No deployment or Workflow launch is selected by this source handoff.

For a later explicitly selected hosted path, GitHub project root would be `cloudflare/prime-learning-worker`; the canonical Artifacts root is `reviews/prime-worker-curriculum-v1/cloudflare/prime-learning-worker`. The same Worker cannot be assumed to have simultaneous independent Artifacts/GitHub build-source connections. Preserve Artifacts custody separately.

This package has no package manifest or added SDK. A proposed later Cloudflare build uses an empty build command, `SKIP_DEPENDENCY_INSTALL=1`, and pinned `npx --yes wrangler@4.147.0 deploy --config wrangler.jsonc` as a reviewed cloud deployment command. That downloads/runs Wrangler in Cloudflare; its transitive toolchain/build image are not fully pinned. Do not activate it merely by connecting source.

Pinned local Wrangler deploy --no-bundle invokes esbuild parsing and may import submitted source with Miniflare after a startup-limit upload error. No local deploy/dry-run/compiler/test/source execution is selected. No credentials are extracted from the existing managed CLI store.

The exact-copy RUN-CONTRACT authority inventory is historical. Later Wrangler metadata verified Workers Scripts Write in addition to Account Read/Artifacts Write and refresh access, but endpoint acceptance remains NOT_TESTED. Builds API configuration authority, the cloud-held build deployment grant, stored provider key and GitHub App repository authorization are separate.

## Qualification

Required hosted observations include disabled gates, invalid payload, fixed US ledger, persistence before dispatch, same-ledger replay, projected safe receipt and deployment consistency. Actual upstream failure/deadline/interruption paths are conditional observations; one allowed inference cannot qualify all of them. Reading status cannot clear the guard or dispatch inference.

All twelve findings remain OPEN. No source corpus, model base, training, R2, Container, Xcode or existing pilot state changes accompany this package.

Sources: [Workflow guide](https://developers.cloudflare.com/workflows/get-started/guide/), [step API](https://developers.cloudflare.com/workflows/build/workers-api/), [idempotency](https://developers.cloudflare.com/workflows/build/rules-of-workflows/), [DO locality](https://developers.cloudflare.com/durable-objects/reference/data-location/), [AI binding](https://developers.cloudflare.com/ai-gateway/usage/worker-binding-methods/), [build configuration](https://developers.cloudflare.com/workers/ci-cd/builds/configuration/).

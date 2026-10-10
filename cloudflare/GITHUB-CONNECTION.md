# Prime Cloudflare to GitHub connection

Owner direction, 2026-10-09: continue to GitHub. Cloudflare remains primary; GitHub is secondary. The selected handoff adds only [the disabled learning Worker package](prime-learning-worker/README.md) and these connection/changelog documents on a new non-main review branch of public `Ergentics/ergentics-prime`. It preserves the existing main tree/history and does not open a PR, train or mirror the full Artifacts collection. This handoff sends no explicit CI/deployment/inference invocation; other installed-app/Cloudflare listeners remain NOT_ASSESSED as recorded below.

## Source and history

Canonical custody: US Artifacts `ergentics-prime-us/ergentics-prime`, source commit `d965b2bf3831f4d6bbe16a4a67ab4d401acd8e3c`, tree `746e82cd735e4f72597d334552a13e361149b484`. The three exact-copy files were originally published at `90603cf8a8a6bceebcfded016541df86ea5bd8c1` and are unchanged in the later source pin. [SOURCE-ORIGIN.json](prime-learning-worker/SOURCE-ORIGIN.json) lists exact paths/hashes.

GitHub base: `c0fb08006755b54d56230d2eb28a84438e00e4a1`, tree `c7ac9898dcccc968a88c2af4e04785761dcb8f9a`. Selected branch: `review/cloudflare-learning-20261009`. The resulting GitHub commit is a child of GitHub's base, not a history replacement with the outer Artifacts collection. Raw scans, source capsules and private review/credential records are excluded. Existing license and third-party notices remain in the inherited tree; no ownership or reuse permission is inferred from tool attribution.

## Account connection still required

Publishing this branch does not establish the Cloudflare GitHub App or Workers Builds connection. Cloudflare's documented sequence first authorizes its GitHub App for the account/organization, then creates a repository connection, then separately creates build triggers and launches a build.

Smallest intended account change: reuse the existing installation, add only `Ergentics/ergentics-prime` to its repository selection, and establish the repository connection without production/preview triggers or a manual build. The existing Backgammon pilot must remain intact. Cloudflare's API separates `PUT /accounts/{account_id}/builds/repos/connections` from trigger/build endpoints; this review does not claim the dashboard can save every intermediate state without building.

The documented Builds API requires a user-scoped token with Workers Builds Configuration Edit; account-scoped tokens are unsupported. Workers Scripts Read is additionally needed only to retrieve a Worker tag. This management credential differs from the cloud-held deployment build token and stored OpenAI BYOK. The current Wrangler Account Read/Artifacts Write/Workers Scripts Write grant does not establish Builds Configuration authority. No token value or new account authorization is requested or handled by this source handoff.

One Worker has one selected build-source connection; do not assume simultaneous Artifacts/GitHub upstreams. Changing that connection is separate from retaining canonical US Artifacts custody. Native Git in a Container can perform a deliberately selected transfer later, but does not create the GitHub App installation, import metadata or automatic sync.

## Automation boundary

The pinned existing workflow `.github/workflows/prime-active-root-quarantine.yml` declares push to main, PRs targeting main and workflow_dispatch. A non-main source branch without a PR does not match its declared automatic events. The handoff commit also carries `[skip ci]` for push/PR events. No workflow file is edited and no workflow dispatch is sent.

Actual workflow enabled state, installed-app automation and existing Cloudflare Builds listeners are NOT_ASSESSED. The checked filters and skip marker are not a universal promise that no external service observes a branch event. No PR (including draft), main update, merge or new build trigger is part of this handoff.

## Later selected hosted path

Project root in GitHub: `cloudflare/prime-learning-worker`. Artifacts root: `reviews/prime-worker-curriculum-v1/cloudflare/prime-learning-worker`. A later explicit cloud build/deployment must review its cloud-held grant, source/ref, disabled activation gates, runtime identity and spent ledger before any Workflow launch. Account connection, code publication, execution and provider completion remain different results.

Official sources: [GitHub integration](https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/github-integration/), [Builds API sequence and permissions](https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/), [build branches](https://developers.cloudflare.com/workers/ci-cd/builds/build-branches/), [Artifacts connection](https://developers.cloudflare.com/workers/ci-cd/builds/git-integration/artifacts-integration/#manage-the-connection), [GitHub skip limits](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs).

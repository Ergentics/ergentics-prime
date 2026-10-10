# Cloudflare source handoff changelog

## 2026-10-09 — disabled learning Worker prepared for GitHub

- Selected the three exact runtime/configuration/contract files from verified US Artifacts commit `d965b2bf3831f4d6bbe16a4a67ab4d401acd8e3c`, with unchanged runtime bytes originally published at `90603cf8a8a6bceebcfded016541df86ea5bd8c1`.
- Adapted README and hosted-pilot instructions for GitHub paths and recorded source hashes/provenance.
- Selected a new non-main review branch built on existing Prime history, with `[skip ci]` and no PR or workflow dispatch.
- Kept all four activation gates false; deployment, hosted fixtures, inference, training and all twelve finding closures remain NOT_RUN/OPEN.
- Distinguished this source handoff from the still-unverified Cloudflare GitHub App/Builds connection and automatic synchronization.

The verified delivery commit/ref is recorded in the Prime Review handoff receipt after readback. This entry describes the package and selected scope; it does not independently prove remote delivery or absence of downstream automation.

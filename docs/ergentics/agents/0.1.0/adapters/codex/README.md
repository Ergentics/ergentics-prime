# Codex native-role adapter

This optional adapter uses the locally observed registry form `agents.<role>` with `description` and `config_file`. Each referenced overlay contains only `developer_instructions`; model and reasoning settings inherit the caller unless separately selected for an actual dispatch. The instructions embed the common contract and role source so a changed working directory does not hide their core behavior. Embedded Markdown links are rebased to an explicitly supplied absolute `BUNDLE_ROOT`; they are not resolved from the TOML file or process working directory.

`config.fragment.toml` uses paths relative to this adapter directory. It is a merge example, not a complete user configuration. If integrated into another configuration file, rebase each `config_file` to that receiving file's location or use its verified absolute path. Preserve existing unrelated configuration. Do not copy a fragment and assume its path base moved with it.

There is also a separate locally observed discovered-role-file format requiring `name` and `developer_instructions`. This adapter does not use that format or assume an automatic discovery directory. A skill's `agents/openai.yaml` is a different interface metadata surface.

The inspected bundled Codex CLI was **0.155.0-alpha.9.2**. Static binary declarations and generated protocol schemas support the observations above; the review did not qualify the native parser, registration, discovery precedence or named-role dispatch. The current collaboration API exposes no `agent_type` selector. Accordingly, native registration/loading is **NOT_PERFORMED / NOT_RUN** for this release.

Use the bundle's explicit [loading route](../../LOAD.md) for the current exposed tools. Future native integration needs a bounded test in the receiving configuration that establishes the selected role and actual injected instructions. Preserve parser/loader failures and positive controls. No global configuration, user agent directory, model setting or runtime permission was changed to prepare this adapter.

Generated overlay identity must continue to match the canonical shared contract and role files when the bundle is updated. The external review receipt records the current generation/identity checks; native schema declarations alone are not an execution result.

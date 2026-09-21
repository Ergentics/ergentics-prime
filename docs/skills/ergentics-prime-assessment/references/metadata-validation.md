# Ergentics shared skill-validation policy

User direction, 2026-09-18: treat PyYAML as the shared Ergentics metadata-validation
dependency for now and keep Auto Harvest and derived skill packages consistent.

## Scope

This default applies to skill metadata validation. Swift remains the first-party
implementation language, with C/C++ at native boundaries. Python/PyYAML is a
validation utility, not a replacement runtime or authority for those sources.
This document is local policy distributed with packages, not proof that an OS,
GitHub organization, Codex account, or hosted runtime setting was changed.

## Reuse the declared dependency

Every affected package includes `scripts/requirements-validation.txt` declaring
`PyYAML>=6.0,<7.0`. This is a compatibility requirement, not an environment lock.
The 6.x range was selected during skill packaging; it is not evidence of a
historical Core AI requirement or proof that an earlier run used that version.
Prefer the existing approved Python environment in local tooling or GitHub CI.
Record its exact Python and PyYAML versions when validation actually runs. Do
not reinstall or upgrade an environment that already satisfies the declaration.

The package contains the dependency declaration and this procedure, not a copy
of site-packages, a virtual environment, or an implicitly installed library.
Do not harvest dependency directories or credentials into a skill archive.

## Select the interpreter, then validate

Use an explicit approved interpreter and validator. A package is named PyYAML
but imported as `yaml`. A missing import establishes only a failure in that
interpreter and invocation mode, not absence everywhere on the Mac or GitHub.

Example for an approved virtual environment; substitute the three named paths:

```sh
validation_python="/absolute/approved/venv/bin/python3"
skill_validator="/absolute/approved/skill-creator/scripts/quick_validate.py"
candidate_skill="/absolute/path/to/the/skill"
"$validation_python" -I -B -c 'import sys, yaml; print("INTERPRETER=" + sys.executable); print("PREFIX=" + sys.prefix); print("PYTHON=" + sys.version.split()[0]); print("YAML_MODULE=" + yaml.__file__); print("PYYAML=" + yaml.__version__); print("PYYAML_IMPORT=PASS")' &&
"$validation_python" -I -B "$skill_validator" "$candidate_skill"
```

Isolated mode (`-I`) excludes the current directory, PYTHONPATH, and user-site
packages. A user-site-only installation can therefore exist but be invisible
to this invocation. Select an approved environment that exposes the dependency;
do not silently inject search paths or repeatedly try the same failing command.
If no approved environment is reachable, retain the scoped NOT_RUN result and
ask for its location or use the already-approved CI workflow. No broad machine
search or global install is needed. Adding or changing CI remains ordinary
repository work, subject to the current task's scope.

## Retain meaningful results

Distinguish dependency import, metadata validation, executable self-tests,
package identity, CI, installation, Git publication, and hosted execution.
A successful import alone does not validate a skill. A declaration inside a ZIP
does not install PyYAML. Keep a failed local attempt as history even when a
different environment passes later.

Bind a CI result to the actual candidate commit or file bytes. A prior GitHub
environment can be reused without rebuilding it, but a prior skill's PASS does
not qualify modified metadata. Do not infer PyYAML availability merely from a
workflow using Python. Record versions, validator identity, scope, exit status,
and result without environment dumps, keys, or credential fingerprints.
For environment provenance, also record the selected interpreter, environment
prefix, and yaml module location. Matching versions alone do not establish
historical continuity; a retained earlier note remains attributed evidence
unless its invocation identity is corroborated.

Update instructions, dependency declaration, validation summary, source manifest,
and generated package together. Preserve issued artifacts. Keep Auto Harvest's
shared policy copy byte-identical to derived packages using this policy. Do not
turn metadata validation into a tokenizer/model run, credential collection,
automatic publication, or a repeated checkpoint workflow.

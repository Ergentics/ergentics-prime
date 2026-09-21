# Scope execution observations to the component and phase

A local packet builder can truthfully record that it made no model dispatch and observed no model-context ingestion. That receipt remains a historical preparation observation after another component uses the packet.

When a hosted agent subsequently reads the packet and produces an answer, record that hosted interaction as observed. Do not copy the builder's NOT_PERFORMED or NOT_OBSERVED fields into the later agent's own execution report. Keep requested model/effort, a visible instruction label and a verified serving-build identity separate; an unknown serving build does not make an observed hosted response disappear.

Positive control: preparation completed locally; the receiving hosted agent read the selected material and returned a response; no additional model/API invocation, native application test or Surface readiness work occurred. Record each fact for its own phase. Provider retention/training controls remain unverified unless separate evidence establishes them.

Golden negative: a later agent says "no hosted processing occurred" solely because the earlier packet receipt says NOT_PERFORMED, even though its own hosted read and response are observed. Reject that inference and preserve the original report with an attributed additive correction. Conversely, when only preparation occurred and no later load is evidenced, retain the preparation-only result; do not invent a hosted load.

This is an authored lesson from two current-task profile-load reports and their preserved corrections. It is method guidance and a known regression control, not proof of universal model compliance, native execution, provider controls or a blind evaluation result. Source reports and evidence pins remain outside the reusable prose; no raw task history is harvested.

import { DurableObject, WorkflowEntrypoint } from "cloudflare:workers";

// Source preparation only. Enabling and deploying this module are separate acts.
// This fixed key must survive redeployment, Workflow replay and status inspection.
const ATTEMPT = "PRIME-AI-BINDING-20261009-01";
const GATEWAY = "default";
const ROUTE = "dynamic/ergentics_learning_v1";
const CALL_ALLOWANCE_MS = 30_000;
const OUTPUT_TEXT_BYTES = 64;
const METADATA = Object.freeze({
  ergentics_scope: "training/cloudflare-learning",
  ergentics_intent: "public-cloudflare-doc-assessment",
  ergentics_admission: "ergentics_learning_v1/public-docs-verified",
  ergentics_batch: "prime-ai-binding-20261009-01",
});
const TERMINAL_STATES = new Set([
  "RESPONSE_OBSERVED",
  "RESPONSE_SHAPE_REFUSED",
  "RESPONSE_ERROR_ENVELOPE",
  "BINDING_REJECTED_UNKNOWN",
  "DEADLINE_UNKNOWN",
  "SETUP_FAILED_CONSUMED",
]);

function plainRecord(value) {
  if (value === null || typeof value !== "object" || Array.isArray(value)) return false;
  const prototype = Object.getPrototypeOf(value);
  return prototype === Object.prototype || prototype === null;
}

function emptyPayload(value) {
  return plainRecord(value) && Reflect.ownKeys(value).length === 0;
}

function boundedVersion(env) {
  const value = env.WORKER_VERSION?.id;
  return typeof value === "string" && /^[A-Za-z0-9_-]{1,80}$/.test(value)
    ? value
    : null;
}

function gatesAttested(env) {
  return env.PILOT_ENABLED === "true"
    && env.PILOT_ROUTE_POLICY_ATTESTED === "true"
    && env.PILOT_DEFAULT_ALIAS_ATTESTED === "true"
    && env.PILOT_FALLBACK_DISABLED_ATTESTED === "true";
}

function nonemptyError(value) {
  return value !== undefined && value !== null && value !== false && value !== ""
    && !(Array.isArray(value) && value.length === 0);
}

function errorEnvelope(value) {
  return value.success === false
    || (Object.hasOwn(value, "error") && nonemptyError(value.error))
    || (Object.hasOwn(value, "errors") && nonemptyError(value.errors));
}

function usageCount(value) {
  return Number.isSafeInteger(value) && value >= 0 && value <= 1_000_000 ? value : null;
}

// Inspect only one fixed envelope/result shape. Never serialize or retain the body.
function responseProjection(value) {
  try {
    return projectResponseShape(value);
  } catch {
    return { state: "RESPONSE_SHAPE_REFUSED" };
  }
}

function projectResponseShape(value) {
  if (!plainRecord(value)) return { state: "RESPONSE_SHAPE_REFUSED" };
  if (errorEnvelope(value)) return { state: "RESPONSE_ERROR_ENVELOPE" };
  const payload = Object.hasOwn(value, "result") ? value.result : value;
  if (!plainRecord(payload)) return { state: "RESPONSE_SHAPE_REFUSED" };
  if (errorEnvelope(payload)) return { state: "RESPONSE_ERROR_ENVELOPE" };
  if (!Array.isArray(payload.choices) || payload.choices.length !== 1) {
    return { state: "RESPONSE_SHAPE_REFUSED" };
  }
  const choice = payload.choices[0];
  if (!plainRecord(choice) || !plainRecord(choice.message)) {
    return { state: "RESPONSE_SHAPE_REFUSED" };
  }
  const message = choice.message;
  if (nonemptyError(message.function_call) || nonemptyError(message.tool_calls)) {
    return { state: "RESPONSE_SHAPE_REFUSED" };
  }
  const text = message.content;
  if (typeof text !== "string" || text.length > OUTPUT_TEXT_BYTES
      || new TextEncoder().encode(text).byteLength > OUTPUT_TEXT_BYTES) {
    return { state: "RESPONSE_SHAPE_REFUSED" };
  }
  const usage = plainRecord(payload.usage) ? payload.usage : {};
  return {
    state: "RESPONSE_OBSERVED",
    answerMatch: text.trim() === "YES" ? 1 : 0,
    promptTokens: usageCount(usage.prompt_tokens),
    completionTokens: usageCount(usage.completion_tokens),
    totalTokens: usageCount(usage.total_tokens),
  };
}

// Authored fixtures run only in the hosted DO; they make no AI or network calls.
function projectionPreflight() {
  const valid = { choices: [{ message: { content: "YES" } }] };
  const cases = [
    [valid, "RESPONSE_OBSERVED", 1],
    [{ error: [{ code: "SYNTHETIC" }] }, "RESPONSE_ERROR_ENVELOPE"],
    [{ errors: [{ code: "SYNTHETIC" }] }, "RESPONSE_ERROR_ENVELOPE"],
    [{ ...valid, errors: [] }, "RESPONSE_OBSERVED", 1],
    [{ ...valid, success: false }, "RESPONSE_ERROR_ENVELOPE"],
    [null, "RESPONSE_SHAPE_REFUSED"],
    [[], "RESPONSE_SHAPE_REFUSED"],
    [{ unknown: true }, "RESPONSE_SHAPE_REFUSED"],
    [{ choices: [{ message: { content: "Y".repeat(OUTPUT_TEXT_BYTES + 1) } }] }, "RESPONSE_SHAPE_REFUSED"],
    [{ success: true, result: valid }, "RESPONSE_OBSERVED", 1],
    [{ result: { ...valid, error: ["SYNTHETIC"] } }, "RESPONSE_ERROR_ENVELOPE"],
  ];
  let passed = 0;
  for (const [input, state, answerMatch] of cases) {
    try {
      const actual = responseProjection(input);
      if (actual.state === state && actual.answerMatch === answerMatch) passed += 1;
    } catch {
      // Never retain a fixture, body, exception or stack in the safe projection.
    }
  }
  return {
    state: passed === cases.length ? "HOSTED_PROJECTION_PREFLIGHT_PASSED" : "HOSTED_PROJECTION_PREFLIGHT_FAILED",
    passed,
    count: cases.length,
  };
}

function noAttempt(state, preflight = null, canonicalLedgerRead = true) {
  return {
    schemaVersion: 1,
    attemptId: ATTEMPT,
    state,
    consumed: canonicalLedgerRead ? false : "UNKNOWN_NOT_READ",
    bindingInvocationSlotsReserved: canonicalLedgerRead ? 0 : "UNKNOWN_NOT_READ",
    currentInvocationBindingCallStarted: false,
    providerExecution: "UNKNOWN_NOT_INDEPENDENTLY_OBSERVED",
    authenticatedHumanPrincipal: "NOT_ESTABLISHED",
    preflight,
  };
}

export class PrimeLearningWorkflow extends WorkflowEntrypoint {
  async run(event, step) {
    if (!emptyPayload(event.payload)) return noAttempt("WORKFLOW_PAYLOAD_REFUSED", null, false);
    // Dashboard/account authorization is not proof of the invoking human's identity.
    return await step.do(
      "fixed-prime-ai-binding-attempt",
      { retries: { limit: 0, delay: "1 second", backoff: "constant" }, timeout: "45 seconds" },
      async () => {
        try {
          const namespace = this.env.RUN_STATE.jurisdiction("us");
          return await namespace.getByName(ATTEMPT).run();
        } catch {
          // The DO may have consumed/dispatched before RPC acknowledgement was lost.
          return {
            schemaVersion: 1,
            attemptId: ATTEMPT,
            state: "DO_RPC_OUTCOME_UNKNOWN",
            consumed: "UNKNOWN",
            retryAllowed: false,
            next: "READ_FIXED_DO_STATUS_ONLY",
          };
        }
      },
    );
  }
}

export class PrimeLearningRun extends DurableObject {
  constructor(ctx, env) {
    super(ctx, env);
    if (!this.#canonicalScope()) throw new Error("FIXED_US_DO_SCOPE_REFUSED");
    ctx.storage.sql.exec(
      "CREATE TABLE IF NOT EXISTS learning_attempt (id TEXT PRIMARY KEY, state TEXT NOT NULL, consumed_at INTEGER NOT NULL, deadline INTEGER NOT NULL, finished_at INTEGER, answer_match INTEGER, prompt_tokens INTEGER, completion_tokens INTEGER, total_tokens INTEGER, version_id TEXT, preflight_passed INTEGER NOT NULL, preflight_count INTEGER NOT NULL)",
    );
  }

  #canonicalScope() {
    try {
      if (this.ctx.id.jurisdiction !== "us") return false;
      const canonical = this.env.RUN_STATE.jurisdiction("us").idFromName(ATTEMPT);
      return this.ctx.id.toString() === canonical.toString();
    } catch {
      return false;
    }
  }

  #row() {
    return this.ctx.storage.sql.exec(
      "SELECT state, consumed_at, deadline, finished_at, answer_match, prompt_tokens, completion_tokens, total_tokens, version_id, preflight_passed, preflight_count FROM learning_attempt WHERE id = ?",
      ATTEMPT,
    ).toArray()[0];
  }

  #projection(row) {
    if (!row) return noAttempt("NOT_CONSUMED");
    const state = row.state === "DISPATCHED" || TERMINAL_STATES.has(row.state)
      ? row.state : "LEDGER_STATE_REFUSED_CONSUMED";
    return {
      schemaVersion: 1,
      attemptId: ATTEMPT,
      state,
      resultState: state === "DISPATCHED"
        ? (Date.now() >= row.deadline ? "DEADLINE_PASSED_OUTCOME_UNKNOWN" : "IN_FLIGHT_OR_INTERRUPTED_UNKNOWN")
        : state,
      consumed: true,
      retryAllowed: false,
      bindingInvocationSlotsReserved: 1,
      consumedAt: row.consumed_at,
      deadline: row.deadline,
      finishedAt: row.finished_at,
      gatewayExpected: GATEWAY,
      routeExpected: ROUTE,
      configuredDOJurisdiction: "us",
      actualDOJurisdictionSourceObserved: this.ctx.id.jurisdiction,
      workerVersionDiagnostic: row.version_id,
      preflight: { state: "HOSTED_PROJECTION_PREFLIGHT_PASSED", passed: row.preflight_passed, count: row.preflight_count },
      sourceDeploymentPin: "NOT_INDEPENDENTLY_VERIFIED",
      ownerPolicyAttestations: "CLOUD_VARIABLE_ATTESTATIONS_NOT_API_READBACK",
      authenticatedHumanPrincipal: "NOT_ESTABLISHED",
      responseShape: state === "RESPONSE_OBSERVED" ? "FIXED_CHAT_COMPLETION_MESSAGE" : "NOT_ACCEPTED",
      expectedAnswerMatched: row.answer_match === 1 ? true : row.answer_match === 0 ? false : null,
      usageSelfReported: {
        promptTokens: row.prompt_tokens,
        completionTokens: row.completion_tokens,
        totalTokens: row.total_tokens,
      },
      requestedMaxTokens: 8,
      byteBudgetScope: "PROJECTED_TEXT_ONLY_NOT_BINDING_WIRE_OR_HEAP",
      providerExecution: "UNKNOWN_NO_INDEPENDENT_PROVIDER_TELEMETRY",
      providerModelIdentity: "UNKNOWN_NOT_INDEPENDENTLY_VERIFIED",
      providerPhysicalAttempts: "UNKNOWN",
      billing: "NOT_OBSERVED",
      cancellation: "NOT_ESTABLISHED",
      corpusOrModelActivation: false,
    };
  }

  async #seal(projection) {
    this.ctx.storage.sql.exec(
      "UPDATE learning_attempt SET state = ?, finished_at = ?, answer_match = ?, prompt_tokens = ?, completion_tokens = ?, total_tokens = ? WHERE id = ? AND state = 'DISPATCHED'",
      projection.state, Date.now(), projection.answerMatch ?? null,
      projection.promptTokens ?? null, projection.completionTokens ?? null,
      projection.totalTokens ?? null, ATTEMPT,
    );
    await this.ctx.storage.sync();
    return this.#projection(this.#row());
  }

  async run() {
    if (!this.#canonicalScope()) return noAttempt("FIXED_US_DO_SCOPE_REFUSED", null, false);
    const existing = this.#row();
    if (existing) return this.#projection(existing);
    const preflight = projectionPreflight();
    if (preflight.state !== "HOSTED_PROJECTION_PREFLIGHT_PASSED") {
      return noAttempt("RESPONSE_PREFLIGHT_REFUSED", preflight);
    }
    if (!gatesAttested(this.env)) return noAttempt("CLOUD_ATTESTATION_GATES_NOT_ENABLED", preflight);
    if (typeof this.env.AI?.run !== "function") return noAttempt("AI_BINDING_UNAVAILABLE", preflight);

    const now = Date.now();
    const deadline = now + CALL_ALLOWANCE_MS;
    const claimed = this.ctx.storage.transactionSync(() => {
      if (this.#row()) return false;
      this.ctx.storage.sql.exec(
        "INSERT INTO learning_attempt (id, state, consumed_at, deadline, version_id, preflight_passed, preflight_count) VALUES (?, 'DISPATCHED', ?, ?, ?, ?, ?)",
        ATTEMPT, now, deadline, boundedVersion(this.env), preflight.passed, preflight.count,
      );
      return true;
    });
    if (!claimed) return this.#projection(this.#row());
    // 'DISPATCHED' means irrevocable call intent, not proof of upstream dispatch.
    // The documented sync barrier precedes the sole binding invocation.
    try {
      await this.ctx.storage.sync();
      await this.ctx.storage.setAlarm(deadline);
      await this.ctx.storage.sync();
    } catch {
      return await this.#seal({ state: "SETUP_FAILED_CONSUMED" });
    }
    const active = this.#row();
    if (active?.state !== "DISPATCHED") return this.#projection(active);
    if (Date.now() >= deadline) return await this.#seal({ state: "DEADLINE_UNKNOWN" });

    let timer;
    // Both fulfillment and rejection are handled even if the deadline wins.
    // Promise.race is a controller deadline; it does not cancel provider work.
    const completion = Promise.resolve().then(() => {
      let latest;
      try {
        latest = this.#row();
      } catch {
        return { kind: "ledgerUnknown" };
      }
      if (!latest) return { kind: "ledgerUnknown" };
      if (latest.state !== "DISPATCHED") return { kind: "closed", row: latest };
      if (latest.deadline !== deadline) return { kind: "ledgerUnknown" };
      if (Date.now() >= latest.deadline) return { kind: "deadline" };
      // No await separates this final admission check from the sole invocation.
      try {
        return Promise.resolve(this.env.AI.run(
          ROUTE,
          {
            messages: [{ role: "user", content: "Does Cloudflare's Workers AI binding expose env.AI? Reply exactly YES or NO." }],
            max_tokens: 8,
            stream: false,
          },
          { gateway: { id: GATEWAY, skipCache: true, collectLog: false, metadata: METADATA } },
        )).then(value => ({ kind: "returned", value }), () => ({ kind: "rejected" }));
      } catch {
        return { kind: "rejected" };
      }
    }).catch(() => ({ kind: "ledgerUnknown" }));

    let outcome;
    try {
      outcome = await Promise.race([
        completion,
        new Promise(resolve => {
          timer = setTimeout(() => resolve({ kind: "deadline" }), Math.max(0, deadline - Date.now()));
        }),
      ]);
    } finally {
      clearTimeout(timer);
    }
    if (outcome.kind === "closed") return this.#projection(outcome.row);
    if (outcome.kind === "ledgerUnknown") {
      return {
        schemaVersion: 1,
        attemptId: ATTEMPT,
        state: "LEDGER_READ_FAILED_CONSUMED_OUTCOME_UNKNOWN",
        consumed: true,
        bindingInvocationSlotsReserved: 1,
        retryAllowed: false,
        next: "READ_FIXED_DO_STATUS_ONLY",
      };
    }
    if (Date.now() >= deadline || outcome.kind === "deadline") {
      return await this.#seal({ state: "DEADLINE_UNKNOWN" });
    }
    if (outcome.kind === "rejected") return await this.#seal({ state: "BINDING_REJECTED_UNKNOWN" });
    return await this.#seal(responseProjection(outcome.value));
  }

  status() {
    if (!this.#canonicalScope()) return noAttempt("FIXED_US_DO_SCOPE_REFUSED", null, false);
    return this.#projection(this.#row());
  }

  async alarm() {
    if (!this.#canonicalScope()) return;
    const row = this.#row();
    if (!row || row.state !== "DISPATCHED") return;
    if (Date.now() < row.deadline) {
      await this.ctx.storage.setAlarm(row.deadline);
      return;
    }
    // An alarm can retry; its only effect is an idempotent terminal record.
    await this.#seal({ state: "DEADLINE_UNKNOWN" });
  }
}

// No public run/status route, preview trigger, schedule or arbitrary RPC proxy.
export default {
  fetch() {
    return new Response(null, { status: 404, headers: { "Cache-Control": "no-store" } });
  },
};

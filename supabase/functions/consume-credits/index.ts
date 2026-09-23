import { json, options } from "../_shared/http.ts";
import { authenticatedClient } from "../_shared/auth.ts";

/** Compatibility endpoint for the canonical consume_credits RPC contract. */
Deno.serve(async req => {
  const pre = options(req); if (pre) return pre;
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  const auth = await authenticatedClient(req, "credits");
  if (auth.response) return auth.response;
  let body: { operation?: string; credits?: number; idempotency_key?: string; provider?: string; model?: string; metadata?: Record<string, unknown> };
  try { body = await req.json(); } catch { return json({ error: "invalid_json" }, 400); }
  if (!body.operation || !body.idempotency_key || typeof body.credits !== "number" || !Number.isFinite(body.credits) || body.credits <= 0) {
    return json({ error: "operation_credits_idempotency_required" }, 400);
  }
  const result = await auth.client!.rpc("consume_credits", {
    p_operation: body.operation,
    p_credits: body.credits,
    p_provider: body.provider || "gemini",
    p_model: body.model || "gemini-2.0-flash",
    p_metadata: { ...(body.metadata || {}), idempotency_key: body.idempotency_key }
  });
  if (result.error) return json({ error: "credit_rpc_failed" }, 503);
  return json({ ok: true, data: result.data, operation: body.operation, idempotency_key: body.idempotency_key });
});

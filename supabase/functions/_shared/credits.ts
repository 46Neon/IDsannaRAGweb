import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export async function reserveCredits(db: SupabaseClient, operation: string, idempotencyKey: string, provider = 'gemini', model = 'gemini-2.0-flash') {
  // Supports both the current deployed contract (p_credits) and the repository contract (p_delta).
  const current = await db.rpc('consume_credits', { p_operation: operation, p_credits: 1, p_provider: provider, p_model: model, p_metadata: { idempotency_key: idempotencyKey } });
  if (!current.error) return { ok: true, data: current.data };
  const legacy = await db.rpc('consume_credits', { p_operation: operation, p_delta: 1, p_idempotency_key: idempotencyKey, p_provider: provider, p_model: model, p_metadata: { idempotency_key: idempotencyKey } });
  if (legacy.error) return { ok: false, code: 'CREDIT_RPC_FAILED' as const };
  return { ok: true, data: legacy.data };
}

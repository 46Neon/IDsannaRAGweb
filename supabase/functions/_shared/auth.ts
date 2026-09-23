import { createClient, type SupabaseClient, type User } from "https://esm.sh/@supabase/supabase-js@2";
import { json } from "./http.ts";

export type AuthResult = {
  response?: Response;
  client?: SupabaseClient;
  user?: User;
};

export async function authenticatedClient(req: Request, bucket?: string): Promise<AuthResult> {
  const authorization = req.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return { response: json({ error: "missing_auth" }, 401) };
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !key) return { response: json({ error: "backend_not_configured" }, 503) };
  const client = createClient(url, key, { global: { headers: { Authorization: authorization } } });
  const { data: { user }, error } = await client.auth.getUser();
  if (error || !user) return { response: json({ error: "invalid_session" }, 401) };
  const token = authorization.slice(7);
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(token));
  const sessionHash = Array.from(new Uint8Array(digest)).map(x=>x.toString(16).padStart(2,'0')).join('');
  const revoked = await client.from('user_sessions').select('id').eq('user_id',user.id).eq('session_hash',sessionHash).not('revoked_at','is',null).maybeSingle();
  if (revoked.data) return { response: json({ error: 'session_revoked' }, 401) };
  await client.from('user_sessions').upsert({user_id:user.id,session_hash:sessionHash,user_agent_hash:'server',last_seen_at:new Date().toISOString()},{onConflict:'session_hash',ignoreDuplicates:false});
  if (bucket) { const { data: allowed, error: rateError } = await client.rpc('consume_rate_limit', { p_bucket: bucket, p_limit: 60, p_window_seconds: 60 }); if (rateError || allowed !== true) return { response: json({ error: 'rate_limited' }, 429) }; }
  return { client, user };
}

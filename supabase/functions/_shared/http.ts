export const corsHeaders = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, apikey, x-client-info, content-type, idempotency-key" };
export function json(data: unknown, status = 200) { return new Response(JSON.stringify(data), { status, headers: { ...corsHeaders, "content-type": "application/json" } }); }
export function options(req: Request) { return req.method === "OPTIONS" ? new Response("ok", { headers: corsHeaders }) : null; }

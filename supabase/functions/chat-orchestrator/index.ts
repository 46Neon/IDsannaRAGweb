import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { configuredProvider } from "../_shared/providers.ts";
import { reserveCredits } from "../_shared/credits.ts";
import { json, options } from "../_shared/http.ts";
import { AGENT_TUPLES as AGENTS, MODEL_CONFIG, systemFor, GLOBAL_RULES } from "../_shared/agent-contract.ts";
import { compileAgentRequest } from "../_shared/runtime-contract.ts";
import { retrieveContext, type Citation } from "../_shared/retrieval.ts";

const clean = (s: string) => s.replace(/<[^>]*>/g, "").trim().slice(0, 12000);
const tokens = (s: string) => new Set(s.toLowerCase().split(/[^a-záéíóúñ0-9]+/).filter(x => x.length > 3));
function choose(message: string, all: boolean, requested?: string) {
  if (requested) return AGENTS.filter(a => a[0] === requested);
  if (all) return AGENTS;
  const t = tokens(message);
  const scores = AGENTS.map(a => ({ a, score: [...tokens(`${a[2]} ${a[3]}`)].filter(x => t.has(x)).length + ([...t].some(x => ["evidencia", "demuestra", "fuente"].includes(x)) && a[0] === "valeria" ? 2 : 0) + ([...t].some(x => ["ejemplo", "aplica", "ejercicio"].includes(x)) && a[0] === "andres" ? 2 : 0) })).sort((x, y) => y.score - x.score);
  return scores.slice(0, 2).map(x => x.a);
}
const citationInstruction = "Usa las referencias [C1], [C2] que aparecen en el contexto. No inventes citas. Si no hay evidencia suficiente, dilo explícitamente.";

Deno.serve(async request => {
  const pre = options(request); if (pre) return pre;
  if (request.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) return json({ error: "missing_auth" }, 401);
  const url = Deno.env.get("SUPABASE_URL"), key = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !key) return json({ error: "backend_not_configured" }, 503);
  const db = createClient(url, key, { global: { headers: { Authorization: authorization } } });
  const { data: { user }, error: authError } = await db.auth.getUser();
  if (authError || !user) return json({ error: "invalid_session" }, 401);
  let input: any; try { input = await request.json(); } catch { return json({ error: "invalid_json" }, 400); }
  const message = clean(input.message || "");
  if (!input.subject_id || !message) return json({ error: "subject_id_and_message_required" }, 400);
  const subject = await db.from("subjects").select("id,name,description").eq("id", input.subject_id).maybeSingle();
  if (subject.error || !subject.data) return json({ error: "subject_not_found_or_forbidden" }, 404);

  let conversationId = input.conversation_id;
  if (conversationId) {
    const c = await db.from("conversations").select("id").eq("id", conversationId).eq("subject_id", input.subject_id).eq("user_id", user.id).maybeSingle();
    if (c.error || !c.data) return json({ error: "conversation_not_found_or_forbidden" }, 404);
  } else {
    const c = await db.from("conversations").insert({ subject_id: input.subject_id, user_id: user.id, title: message.slice(0, 80) }).select("id").single();
    if (c.error) return json({ error: "conversation_create_failed" }, 500);
    conversationId = c.data.id;
  }
  await db.from("messages").insert({ conversation_id: conversationId, user_id: user.id, role: "user", content: message });

  let retrieval: { context: string; citations: Citation[] };
  try { retrieval = await retrieveContext(db, message, input.subject_id, input.retrieval_limit || 8); }
  catch (e) { return json({ error: String(e).includes("embedding_provider") ? "EMBEDDING_PROVIDER_NOT_CONFIGURED" : "RETRIEVAL_FAILED", conversation_id: conversationId }, 503); }
  if (!retrieval.citations.length) return json({ ok: true, status: "insufficient_context", conversation_id: conversationId, answer: { text: "No encontré evidencia suficiente en los documentos de esta materia para responder con seguridad.", agent_id: "idsanna", confidence: 0, citations: [] }, agents: [], retrieval: { query: message, chunks_used: 0, results: [] }, credits: { reserved: 0, consumed: 0 } });

  const selected = choose(message, input.all_agents === true, input.agent_id);
  const results = await Promise.all(selected.map(async ([id, name, trait, behavior]) => {
    const reservation = await reserveCredits(db, `agent_${id}`, `${input.idempotency_key || crypto.randomUUID()}_${id}`, "groq", MODEL_CONFIG[id]?.model || "openai/gpt-oss-20b");
    if (!reservation.ok) return { id, name, status: "failed", error: "credit_unavailable", citations: [] };
    const provider = configuredProvider(id);
    if (!provider) return { id, name, status: "failed", error: "provider_not_configured", citations: [] };
    const ir = compileAgentRequest({ agent: id, subjectId: input.subject_id, unitId: input.unit, conversationId, context: retrieval.context });
    const system = `${systemFor([id, name, trait, behavior], subject.data.name, input.unit || "", ir.context)} ${citationInstruction}`;
    try {
      const cfg = MODEL_CONFIG[id] || MODEL_CONFIG.carlos;
      const response = await provider.complete({ agentId: id, system, user: message, model: cfg.model, temperature: cfg.temperature });
      await db.from("messages").insert({ conversation_id: conversationId, user_id: user.id, role: "assistant", agent_id: id, content: response.text, citations: retrieval.citations, usage: response.usage });
      return { id, name, trait, status: "completed", text: response.text, provider: response.provider, model: response.model, usage: response.usage, citations: retrieval.citations };
    } catch { return { id, name, status: "failed", error: "agent_failed", citations: [] }; }
  }));

  let synthesis: any = null;
  const successful = results.filter((x: any) => x.status === "completed" && x.text);
  const synthesizer = configuredProvider("IDSANNA");
  if (synthesizer && successful.length) {
    try {
      const perspectives = successful.map((x: any) => `${x.name}: ${x.text}`).join("\n");
      const response = await synthesizer.complete({ agentId: "IDSANNA", system: `${GLOBAL_RULES} Eres IDsanna, sintetizador académico. Integra perspectivas, conserva desacuerdos, indica certeza y termina con una pregunta de autoevaluación. ${citationInstruction}`, user: `Contexto de la materia: ${retrieval.context}\nPerspectivas:\n${perspectives}`, model: MODEL_CONFIG.idsanna.model, temperature: MODEL_CONFIG.idsanna.temperature });
      synthesis = { id: "idsanna", name: "IDsanna", status: "completed", text: response.text, citations: retrieval.citations, usage: response.usage };
      await db.from("messages").insert({ conversation_id: conversationId, user_id: user.id, role: "assistant", agent_id: "idsanna", content: response.text, citations: retrieval.citations, usage: response.usage });
    } catch { synthesis = { id: "idsanna", name: "IDsanna", status: "failed", error: "synthesis_failed", citations: [] }; }
  }
  const answer = synthesis?.text ? synthesis : successful[0] || { id: "idsanna", name: "IDsanna", status: "failed", text: "No se pudo generar una respuesta.", citations: [] };
  return json({ ok: true, status: successful.length === selected.length ? "completed" : "partial", conversation_id: conversationId, answer: { text: answer.text, agent_id: answer.id, confidence: retrieval.citations[0]?.similarity || 0, citations: answer.citations || [] }, agents: results, synthesis, retrieval: { query: message, chunks_used: retrieval.citations.length, results: retrieval.citations }, credits: { reserved: selected.length + (synthesis ? 1 : 0), consumed: successful.length + (synthesis ? 1 : 0) }, facilitators: ["Evaluar respuesta", "Corregir concepto", "Dar la palabra a otro alumno", "Pedir evidencia"] });
});

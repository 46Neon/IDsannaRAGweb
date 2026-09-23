import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type Citation = {
  citation_id: string;
  document_id: string;
  chunk_id: string;
  chunk_index?: number;
  document_name?: string;
  page?: number;
  timestamp_start?: number;
  timestamp_end?: number;
  similarity: number;
  quote: string;
  source_url?: string;
};

async function embed(text: string) {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) throw new Error("embedding_provider_not_configured");
  const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/text-embedding-004:embedContent?key=${encodeURIComponent(key)}`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ model: "models/text-embedding-004", content: { parts: [{ text }] } })
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || !Array.isArray(data.embedding?.values)) throw new Error("embedding_failed");
  return data.embedding.values;
}

export async function retrieveContext(db: SupabaseClient, query: string, subjectId: string, limit = 8) {
  const embedding = await embed(query);
  const result = await db.rpc("match_document_chunks", {
    query_embedding: embedding,
    match_threshold: 0.35,
    match_count: Math.min(Math.max(limit, 1), 20),
    filter_subject_id: subjectId
  });
  if (result.error) throw new Error("retrieval_failed");
  const citations: Citation[] = (result.data || []).map((row: any, index: number) => {
    const metadata = row.metadata || {};
    return {
      citation_id: `C${index + 1}`,
      document_id: row.document_id,
      chunk_id: row.id,
      chunk_index: metadata.chunk_index,
      document_name: metadata.file_name || metadata.document_name,
      page: metadata.page,
      timestamp_start: metadata.timestamp_start,
      timestamp_end: metadata.timestamp_end,
      similarity: Number(row.similarity || 0),
      quote: String(row.content || "").slice(0, 900),
      source_url: metadata.source_url
    };
  });
  const context = citations.map(c => `[${c.citation_id}] ${c.document_name || "Documento"}${c.page ? `, página ${c.page}` : ""}\n${c.quote}`).join("\n\n").slice(0, 16000);
  return { context, citations };
}

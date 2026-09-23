Deno.serve(() => new Response(JSON.stringify({ ok: true, service: "idsanna" }), { headers: { "content-type": "application/json" } }));

# Arquitectura Android de IDsannaRAG

## Capas
- `MainActivity`: shell mínimo y seguro del WebView; no contiene secretos ni lógica de negocio.
- `app/src/main/assets/index.html`: UI mobile-first y accesible.
- `config.example.json`: contrato de configuración pública; nunca incluir valores reales en Git.
- Supabase: Auth, PostgreSQL, Storage, RLS, Edge Functions y Realtime.
- Gemini/Groq/OpenAI: únicamente desde Edge Functions.

## Flujo previsto
1. Auth obtiene la sesión de Supabase.
2. El cliente consulta solo datos permitidos por RLS.
3. Las cargas se guardan en Storage privado con rutas por usuario.
4. El cliente invoca Edge Functions con el JWT de sesión.
5. La función valida usuario, materia, permisos, créditos e idempotencia.
6. El contexto RAG se trata como datos no confiables y se devuelve con citas.

## Estado de esta versión
La APK contiene una shell y UI verificables. La integración de red debe añadirse junto con las Edge Functions reales; no se simula autenticación, RAG ni persistencia.

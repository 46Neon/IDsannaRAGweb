# Supabase de IDsanna

Supabase es la única persistencia. Las migraciones se aplican desde el SQL Editor o Supabase CLI y deben verificarse después.

## Secrets de Edge Functions
- `GEMINI_API_KEY`
- `SUPABASE_SERVICE_ROLE_KEY` (inyectada por Supabase cuando corresponda)

Nunca guardar estos valores en GitHub, el APK, assets, HTML, JavaScript o logs.

## Contrato público del cliente
- URL del proyecto Supabase.
- Clave pública/publishable.
- JWT de la sesión de Supabase Auth.

## Funciones
- `health`: prueba no sensible de disponibilidad.
- `chat-orchestrator`: valida JWT, materia, permisos y créditos antes de llamar a Gemini. Esta primera implementación devuelve estado claro si faltan tablas/configuración; no simula una respuesta de IA.

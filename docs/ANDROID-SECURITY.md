# Seguridad Android

La APK no puede proteger una API key privada: cualquier secreto compilado puede extraerse. Por eso:

- `PublicConfig` solo representa URL y clave pública/publishable de Supabase.
- `SecureSessionStore` usa Android Keystore para tokens de sesión de corta duración.
- Gemini, Groq, OpenAI y `SUPABASE_SERVICE_ROLE_KEY` viven únicamente en Edge Functions.
- No se incluyen certificados, keystores de firma, tokens ni blobs binarios privados.
- La firma release se debe hacer en GitHub Actions con secrets del repositorio/entorno.

Un binario no reemplaza la arquitectura de seguridad. El APK debe pedir una sesión real a Supabase Auth y enviar su JWT a Edge Functions.

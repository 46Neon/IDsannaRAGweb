# IDsannaRAG

Mini-RAG educativo para Android 11+ que organiza materias, unidades y documentos, y prepara una sala de chat con siete agentes académicos y AI 8 como sintetizador.

## Estado actual

Esta versión es una build de usabilidad. La APK permite probar la shell Android, la navegación Inicio/Suite/Chat/Perfil/Acceso, el selector de archivos, el runtime local y la configuración de sesión. Las capacidades remotas de Auth, Storage, procesamiento multimodal, embeddings, RAG, agentes Groq, evaluación y créditos solo se consideran operativas después de validarse contra Supabase.

La arquitectura utiliza:

- Android WebView local y Java 17.
- Gradle 8.10.2, `minSdk 30` y `compileSdk 35`.
- Supabase Auth, PostgreSQL, Storage, RLS y Edge Functions.
- Runtime y compilador unificados.
- Carlos, Valeria, Karla, Andrés, Juan, Mónica, Julia y AI 8.
- RAG para PDF, audio transcrito, imágenes/OCR y fragmentos vectoriales.
- Perfil de aprendizaje, evaluaciones, feed, recomendaciones y créditos.

## Construir localmente

Requiere JDK 17 y Gradle 8.10.2:

```bash
gradle test lintDebug assembleDebug --no-daemon
```

La salida debug queda en:

```text
app/build/outputs/apk/debug/app-debug.apk
```

## Descargar la APK de prueba

La build se genera mediante GitHub Actions en el workflow **Android CI**. Para descargarla:

1. Abre el repositorio `46Neon/IDsannaRAG` en GitHub.
2. Entra en la pestaña **Actions**.
3. Selecciona **Android CI**.
4. Abre la ejecución más reciente con estado verde.
5. Desplázate hasta **Artifacts**.
6. Descarga `idsanna-rag-debug-apk`.
7. Extrae el ZIP y usa `app-debug.apk` en Android 11 o superior.

La build manual también puede iniciarse desde **Actions → Android CI → Run workflow → main**. El artefacto de Actions no es una release permanente y puede caducar según la retención de GitHub.

## Configuración de Supabase

Para que la APK se conecte al backend, `app/src/main/assets/config.json` debe contener únicamente la URL pública y la clave publishable de Supabase:

```json
{
  "supabaseUrl": "https://wngojaotfjztpcdijwvp.supabase.co",
  "supabasePublishableKey": "CLAVE_PUBLICA_PUBLISHABLE"
}
```

No se deben incluir en Android:

```text
GEMINI_API_KEY
GROQ_API_KEY
OPENAI_API_KEY
SUPABASE_SERVICE_ROLE_KEY
SUPABASE_ACCESS_TOKEN
```

Las claves privadas permanecen en Supabase Edge Functions.

## Seguridad

El cliente utiliza sesiones persistentes, timeout, reintentos, `request_id`, HTTPS, WebView con acceso local restringido y separación de secretos. La autenticación real, RLS, aislamiento multiusuario, procesamiento documental, créditos y Edge Functions deben validarse con pruebas autenticadas antes de declararse producción.

## Release

El workflow **Release APK** se ejecuta con un tag `v*` o manualmente. Las builds debug sirven para usabilidad; las builds release deben firmarse con un mecanismo de firma configurado antes de distribuirlas fuera de pruebas.

## Documentación

La arquitectura se describe en `docs/ARCHITECTURE.md`, la instalación en `docs/INSTALL.md`, la integración en `docs/SUPABASE-INTEGRATION.md`, la seguridad en `docs/ANDROID-SECURITY.md` y el estado verificable en `docs/STATUS.md`.

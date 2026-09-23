# Estado de implementación

## Preparado en código
- Shell Android/WebView local.
- UI mobile-first de Inicio, Suite, Chat, Perfil y Acceso.
- Contratos de configuración pública.
- Esqueleto Supabase, migración no destructiva y Edge Functions con validación.
- Workflows Android CI y Release.
- Auditoría y plan por fases.

## Aún no verificado
- Aplicación de migraciones en el proyecto Supabase.
- Login real y políticas RLS en producción.
- Extracción de documentos y embeddings.
- Orquestación real de Gemini/Groq/OpenAI.
- Consumo atómico de créditos contra la base.
- Realtime, Storage e integración móvil.
- Build ejecutado en GitHub Actions.
- APK instalada en un dispositivo Android.

## Prohibiciones actuales
No incluir claves privadas, no afirmar que el RAG está terminado, no simular pagos, no simular respuestas de agentes y no usar Firebase/Firestore como persistencia paralela.

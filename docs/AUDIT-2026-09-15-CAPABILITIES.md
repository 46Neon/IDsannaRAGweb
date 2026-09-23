# Auditoría de capacidades de IDsanna — 2026-09-15

## Alcance
Auditoría estática del repositorio después de incorporar el runtime unificado, CRUD, metadatos, ingestión, feed, Groq, Wikipedia y accesibilidad browser-only. No sustituye una prueba end-to-end remota.

## Capacidades implementadas

| Área | Estado del repositorio | Evidencia | Riesgo pendiente |
|---|---|---|---|
| Runtime unificado | Preparado | `idsanna-runtime`, `idsanna-compiler.js` | Debe verificarse desplegado y con respuestas reales |
| Cinco interfaces | Implementadas | Inicio, Suite, Chat, Perfil, Acceso | Parte de la UX aún depende de configuración pública |
| CRUD | Alto nivel preparado | `crud-engine`, versionado, estados, auditoría | Falta probar conflictos, RLS y restauración en remoto |
| Metadatos | Amplio | schemas, fields, rules, tags, views, workflows, versions, events | Falta consumir más metadatos para generar toda la UI |
| Auth | Parcial-alto | registro, login, recuperación, logout | Falta confirmar correo, refresh de sesión y políticas de cuenta |
| RAG | Arquitectura completa | Storage, extracción, chunks, embeddings, retrieval y citas | No verificado con archivos reales y Secret Gemini remoto |
| PDF/imagen/audio | Código preparado | Storage + procesamiento multimodal | Límites de tamaño, coste y formatos deben probarse |
| Evaluación | Funcional inicial | rúbrica 1–20, APA básica, métricas | “OPEL” no tiene definición institucional entregada |
| Créditos | Preparado | reserva, ledger, finalización, fallback de RPC | Falta prueba real de saldo, reembolso e idempotencia |
| Groq | Mejorado | claves por agente, general, retry y fallback | Las 8 claves deben existir como Secrets |
| Feed | Mejorado | feed_posts + Wikipedia API + enlaces navegador | Falta cache/curación y control de fuentes en producción |
| MCP | No instalado | arquitectura compatible | Falta gateway y servidores allowlisted |
| Accesibilidad | Browser-only | allowlist de navegadores | Acciones de escritura deben exigir consentimiento por operación |

## Hallazgos críticos

1. `app/src/main/assets/config.json` no contiene URL ni publishable key; esto evita empaquetar credenciales inválidas, pero bloquea pruebas reales desde la APK.
2. Los despliegues dependen de `SUPABASE_ACCESS_TOKEN`, `SUPABASE_PROJECT_REF` y Secrets de Edge Functions.
3. La validación CI es principalmente estática; no existe todavía una prueba autenticada end-to-end con archivos y proveedor IA.
4. Wikipedia se consulta mediante Edge Function y se abre en navegador con enlace; no debe permitirse scraping o automatización arbitraria.
5. MCP debe operar con allowlist, permisos por herramienta, auditoría y confirmación para toda acción que escriba, publique, envíe o interactúe con una página.
6. Los términos y consentimiento deben persistirse antes de crear la cuenta.

## Veredicto

**IDsanna tiene altas capacidades arquitectónicas y un runtime amplio, pero la operación completa todavía requiere configuración remota y pruebas reales.** No debe declararse producción completa hasta verificar despliegues, Secrets, Auth, Storage, archivos, embeddings, retrieval, chat, créditos y consentimiento legal.

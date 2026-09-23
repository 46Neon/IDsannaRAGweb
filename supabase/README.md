# Backend Supabase de IDsannaRAG Web

Este directorio contiene exclusivamente la configuración y el backend Supabase de la aplicación web IDsannaRAG. No contiene una interfaz de usuario; el frontend web construido en v0 debe conectarse a estos servicios mediante HTTPS y la sesión de Supabase Auth.

## Componentes

- `migrations/`: esquema relacional, permisos RLS, RPC y soporte vectorial.
- `functions/`: autenticación, materias, feed, carga y procesamiento documental, recuperación RAG, chat, metadatos y créditos.
- `tests/`: notas y casos de validación del backend.
- `config.toml`: configuración local de Supabase.

## Integración desde la aplicación web

1. Configura en el entorno del frontend únicamente la URL del proyecto Supabase y la clave pública/publishable.
2. Usa Supabase Auth para registro, login, verificación de correo, recuperación de contraseña y sesión web.
3. Envía las llamadas a Edge Functions por HTTPS con el JWT de la sesión autenticada.
4. Deja que RLS controle el acceso a filas; no confíes en identificadores o roles enviados por el navegador.
5. Sube documentos a Storage privado y verifica la propiedad del usuario y la materia en el backend.

No pongas claves de proveedor, `service_role`, tokens administrativos ni secretos en el navegador, variables `NEXT_PUBLIC_*`, HTML, JavaScript, el repositorio o los logs. Configura las claves de Groq, Gemini y otros proveedores únicamente como secretos del backend.

## Desarrollo y despliegue

Aplica las migraciones con Supabase CLI en un proyecto local o de prueba antes de desplegarlas. Configura los secretos requeridos para Edge Functions y valida el esquema, RLS, Storage, Auth, recuperación RAG, créditos e idempotencia con pruebas autenticadas. No declares operativo un flujo hasta probarlo contra el proyecto correspondiente.

## Estado y límites

Este directorio es el backend de Supabase para la aplicación web. La interfaz web debe vivir en el frontend del proyecto y consumir estos contratos. La función `ingest-document` actual recibe PDF, imágenes o audio en Base64; el soporte de otros formatos debe agregarse y probarse explícitamente antes de mostrarlos como compatibles en la interfaz.

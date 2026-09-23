# Estructura del proyecto

- `app/`: aplicación Android y assets locales.
- `supabase/migrations/`: cambios de esquema revisables y no destructivos.
- `supabase/functions/`: lógica server-side; ningún secreto llega al cliente.
- `supabase/tests/`: matriz de seguridad y aislamiento.
- `docs/`: auditoría, arquitectura, roadmap y estado.
- `tests/`: criterios de prueba multiplataforma.
- `.github/workflows/`: automatización posterior a la fase de archivos.

La creación de workflows no sustituye la ejecución de CI. La creación de una migración no demuestra que Supabase la haya aplicado.

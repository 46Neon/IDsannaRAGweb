# Instalación y ejecución

## Android
1. Instalar JDK 17 y Android SDK 35.
2. Abrir el proyecto en Android Studio o usar Gradle 8.10.2.
3. Copiar la configuración pública en `app/src/main/assets/config.json` solo con URL y clave publishable.
4. Ejecutar `gradle assembleDebug`.
5. No incluir secretos de IA ni `service_role` en `config.json`.

## Supabase
1. Revisar `supabase/migrations` contra el proyecto existente.
2. Aplicar migraciones desde Supabase CLI/SQL Editor.
3. Verificar tablas, extensiones, RLS, Storage y funciones.
4. Configurar secrets únicamente en Edge Functions.
5. Ejecutar la matriz de `supabase/tests` con dos usuarios.

## Edge Functions
El cliente usa JWT de Supabase Auth. Cada función debe validar usuario, pertenencia a materia, límites e idempotencia antes de leer o escribir.

## Verificación
No considerar una fase completada por tener archivos: registrar comandos, resultado y evidencia en `docs/STATUS.md`.

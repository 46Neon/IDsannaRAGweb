# Dependencias Android

Las dependencias se resuelven por Gradle para evitar binarios manuales no auditados:

- AndroidX Core: compatibilidad base.
- AndroidX Activity: ciclo de vida y actividades extensibles.
- AndroidX Lifecycle: observación de estado.
- AndroidX WebKit: WebView segura y carga de assets.
- Material Components: componentes accesibles para la evolución de la UI.
- OkHttp: cliente HTTP preparado para servicios Supabase/Edge Functions.
- DocumentFile: selección y manejo compatible de documentos.
- WorkManager: tareas diferidas y reintentables, sin ejecutar acciones autónomas sobre otras apps.
- AndroidX Annotation: contratos estáticos.
- JUnit y Espresso: pruebas unitarias y de interfaz.

Ninguna dependencia recibe API keys privadas. Las claves de IA siguen restringidas a Edge Functions.

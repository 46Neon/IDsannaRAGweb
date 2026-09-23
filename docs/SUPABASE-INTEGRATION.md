# Integración Supabase del cliente

La app usa un cliente REST mínimo para mantener el APK liviano. El asset `config.json` solo contiene configuración pública y en el repositorio permanece con placeholders.

Antes de ejecutar en un proyecto real:

1. Copiar URL y clave publicable de Supabase en la configuración de build/asset.
2. No incluir service role ni claves de proveedores.
3. Crear una sesión con Auth.
4. Enviar el JWT en cada consulta REST y llamada de Edge Function.
5. Comprobar RLS con dos usuarios.

Sin configuración pública real, la aplicación muestra estado pendiente y no finge persistencia.

La configuración pública de Android puede contener la clave publishable del proyecto. No debe contener la clave service role ni claves de proveedores de IA. El archivo de ejemplo permanece vacío para no acoplar otros proyectos.

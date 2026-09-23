# Binarios y APK

No se agregan binarios con claves privadas. Eso sería inseguro y no permitiría protegerlas. La compilación reproducible genera el APK desde el código mediante Gradle/GitHub Actions.

Los únicos datos que pueden llegar al cliente son la URL de Supabase y su clave pública/publishable. Los secretos de IA y la service role se inyectan en Edge Functions durante el despliegue.

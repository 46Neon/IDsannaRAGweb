# Accesibilidad Android

IDsanna incluye un servicio opcional y pasivo para integración nativa de accesibilidad.

## Límites de seguridad

- El usuario debe activarlo manualmente desde los ajustes de Android.
- No pulsa botones.
- No escribe texto en otras aplicaciones.
- No navega de forma autónoma.
- No lee el contenido de ventanas.
- No envía mensajes.
- No planifica ni ejecuta acciones de terceros.
- No sustituye la interacción explícita del usuario.

El servicio solo existe como puente de ciclo de vida para futuras funciones asistivas claramente visibles. Cualquier capacidad futura que interactúe con otra aplicación debe requerir confirmación explícita, tener modo simulación, registro visible y botón de detener.

## Política de autonomía

No se habilita automatización externa irrestricta. El proyecto solo puede evolucionar hacia acciones asistidas con simulación, allowlist, confirmación humana, auditoría y detención inmediata.

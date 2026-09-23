# Acciones asistidas y autonomía

IDsanna no habilita control autónomo irrestricto de otras aplicaciones mediante AccessibilityService.

La base segura para futuras acciones asistidas es:

- Modo simulación activado por defecto.
- Lista explícita de acciones permitidas.
- Confirmación humana antes de cada acción externa.
- Registro visible de acción, objetivo, hora y resultado.
- Botón de detención inmediata.
- Sin lectura de contraseñas, tokens o contenido privado no necesario.
- Sin envío de mensajes, compras, publicaciones o cambios irreversibles sin confirmación.
- El servicio de accesibilidad permanece pasivo.

`ActionPolicy` y `ActionRecord` solo preparan estos controles; no ejecutan acciones externas por sí mismos.

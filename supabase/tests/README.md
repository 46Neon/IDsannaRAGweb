# Supabase verification matrix

Ejecutar en un proyecto de prueba antes de producción:

1. Dos usuarios no pueden leer materias ni documentos ajenos.
2. Un miembro puede leer una materia, pero no modificarla si no es owner.
3. `document_chunks` no filtra chunks de otra materia.
4. La cuenta de créditos nunca baja de cero.
5. La misma idempotency key no cobra dos veces.
6. Un JWT expirado no accede a Edge Functions protegidas.
7. Los secretos no aparecen en respuestas, logs ni tablas públicas.

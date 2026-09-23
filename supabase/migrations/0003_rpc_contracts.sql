-- Contrato de transacciones. No habilitar cobros hasta probarlo con pgTAP/SQL.
-- La implementación final debe ser SECURITY DEFINER, validar auth.uid(),
-- bloquear credit_accounts FOR UPDATE, rechazar saldo negativo y garantizar
-- unique(user_id,idempotency_key).
create or replace function public.health_contract() returns jsonb language sql stable as $$ select jsonb_build_object('service','idsanna','version','foundation') $$;

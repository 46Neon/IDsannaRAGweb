-- Reconciles projects created from the earlier credit_balances contract.
-- Idempotent: it only adds missing runtime objects and does not drop data.
create table if not exists public.credit_ledger (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null, operation_type text not null, provider text, model text,
  idempotency_key text not null, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), unique(user_id,idempotency_key)
);
create table if not exists public.agent_profiles (
  id text primary key, display_name text not null, role_description text not null,
  enabled boolean not null default true, metadata jsonb not null default '{}'::jsonb
);
insert into public.agent_profiles(id,display_name,role_description) values
 ('carlos','Carlos','Perspectiva analítica y estructurada'),('valeria','Valeria','Perspectiva crítica y de evidencia'),('karla','Karla','Perspectiva creativa y pedagógica'),('andres','Andrés','Perspectiva práctica y aplicada'),('juan','Juan','Perspectiva técnica y verificable'),('monica','Mónica','Perspectiva de síntesis y comunicación'),('julia','Julia','Perspectiva de evaluación y metacognición'),('idsanna','IDsanna','Supervisión y síntesis')
on conflict(id) do nothing;
alter table public.credit_ledger enable row level security;
alter table public.agent_profiles enable row level security;
drop policy if exists credit_ledger_self on public.credit_ledger;
create policy credit_ledger_self on public.credit_ledger for select using (user_id=auth.uid());
drop policy if exists agent_profiles_read on public.agent_profiles;
create policy agent_profiles_read on public.agent_profiles for select using (true);
create index if not exists credit_ledger_user_idx on public.credit_ledger(user_id,created_at desc);

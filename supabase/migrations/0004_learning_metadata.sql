-- Capacidades académicas y metadatos. No contiene pagos ni secretos.
create table if not exists public.study_groups (id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade, owner_id uuid not null references auth.users(id) on delete cascade, name text not null, created_at timestamptz not null default now());
create table if not exists public.memories (id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, agent_id text not null references public.agent_profiles(id), content text not null, importance smallint not null default 1 check(importance between 1 and 5), created_at timestamptz not null default now());
create table if not exists public.evaluations (id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, document_id uuid references public.documents(id) on delete set null, score smallint check(score between 1 and 20), rubric jsonb not null default '{}'::jsonb, feedback text, created_at timestamptz not null default now());
create table if not exists public.learning_events (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, subject_id uuid references public.subjects(id) on delete set null, event_type text not null, payload jsonb not null default '{}'::jsonb, created_at timestamptz not null default now());
create table if not exists public.metadata_schemas (id uuid primary key default gen_random_uuid(), owner_id uuid references auth.users(id) on delete cascade, scope text not null default 'subject', name text not null, version integer not null default 1, definition jsonb not null, enabled boolean not null default true, created_at timestamptz not null default now(), unique(owner_id,name,version));
create table if not exists public.subscription_events (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, provider text not null, external_id text not null, status text not null, amount_cents integer, payload jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), unique(provider,external_id));

alter table public.study_groups enable row level security; alter table public.memories enable row level security; alter table public.evaluations enable row level security; alter table public.learning_events enable row level security; alter table public.metadata_schemas enable row level security; alter table public.subscription_events enable row level security;
drop policy if exists study_groups_member on public.study_groups; create policy study_groups_member on public.study_groups for all using (owner_id=auth.uid() or exists(select 1 from public.subject_members m where m.subject_id=subject_id and m.user_id=auth.uid())) with check (owner_id=auth.uid());
drop policy if exists memories_self on public.memories; create policy memories_self on public.memories for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists evaluations_self on public.evaluations; create policy evaluations_self on public.evaluations for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists events_self on public.learning_events; create policy events_self on public.learning_events for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists metadata_owner on public.metadata_schemas; create policy metadata_owner on public.metadata_schemas for all using(owner_id=auth.uid()) with check(owner_id=auth.uid());
drop policy if exists subscription_self on public.subscription_events; create policy subscription_self on public.subscription_events for select using(user_id=auth.uid());

create or replace function public.consume_credits(p_operation text, p_delta integer, p_idempotency_key text, p_provider text default null, p_model text default null, p_metadata jsonb default '{}'::jsonb)
returns table(applied boolean, balance integer) language plpgsql security definer set search_path=public as $$
declare current_balance integer; existing_delta integer;
begin
  if auth.uid() is null or p_delta <= 0 or p_idempotency_key is null or length(p_idempotency_key) > 160 then raise exception 'invalid_credit_request'; end if;
  insert into credit_accounts(user_id,balance) values(auth.uid(),1000) on conflict(user_id) do nothing;
  select balance into current_balance from credit_accounts where user_id=auth.uid() for update;
  select delta into existing_delta from credit_ledger where user_id=auth.uid() and idempotency_key=p_idempotency_key;
  if existing_delta is not null then return query select false,current_balance; return; end if;
  if current_balance < p_delta then raise exception 'insufficient_credits'; end if;
  update credit_accounts set balance=balance-p_delta,updated_at=now() where user_id=auth.uid();
  insert into credit_ledger(user_id,delta,operation_type,provider,model,idempotency_key,metadata) values(auth.uid(),-p_delta,p_operation,p_provider,p_model,p_idempotency_key,p_metadata);
  return query select true,current_balance-p_delta;
end; $$;
revoke all on function public.consume_credits(text,integer,text,text,text,jsonb) from public;
grant execute on function public.consume_credits(text,integer,text,text,text,jsonb) to authenticated;

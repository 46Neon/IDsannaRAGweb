-- Fundación de IDsanna. Revisar contra el esquema existente antes de aplicar.
create extension if not exists vector with schema extensions;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  plan text not null default 'freemium' check (plan in ('freemium','pro')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 160), description text, metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.subject_members (
  subject_id uuid references public.subjects(id) on delete cascade, user_id uuid references auth.users(id) on delete cascade,
  role text not null default 'student' check (role in ('owner','student','teacher')), created_at timestamptz not null default now(),
  primary key(subject_id,user_id)
);
create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade, storage_path text not null, filename text not null,
  mime_type text, status text not null default 'queued' check(status in ('queued','processing','ready','failed')),
  metadata jsonb not null default '{}'::jsonb, error_message text, created_at timestamptz not null default now()
);
create table if not exists public.document_chunks (
  id uuid primary key default gen_random_uuid(), document_id uuid not null references public.documents(id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade, chunk_index integer not null,
  content text not null, metadata jsonb not null default '{}'::jsonb, embedding extensions.vector(1536),
  unique(document_id,chunk_index)
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(), subject_id uuid not null references public.subjects(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade, title text, created_at timestamptz not null default now()
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(), conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade, role text not null check(role in ('user','assistant','system')),
  agent_id text, content text not null, citations jsonb not null default '[]'::jsonb, usage jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create table if not exists public.credit_accounts (
  user_id uuid primary key references auth.users(id) on delete cascade, balance integer not null default 1000 check(balance >= 0), updated_at timestamptz not null default now()
);
create table if not exists public.credit_ledger (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  delta integer not null, operation_type text not null, provider text, model text, idempotency_key text not null,
  metadata jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(), unique(user_id,idempotency_key)
);
create table if not exists public.credit_rules (
  id uuid primary key default gen_random_uuid(), operation_type text not null, provider text not null, model text not null,
  input_unit_cost numeric not null default 0, output_unit_cost numeric not null default 0, enabled boolean not null default true, unique(operation_type,provider,model)
);
create table if not exists public.agent_profiles (
  id text primary key, display_name text not null, role_description text not null, enabled boolean not null default true, metadata jsonb not null default '{}'::jsonb
);
insert into public.agent_profiles(id,display_name,role_description) values
 ('carlos','Carlos','Perspectiva analítica y estructurada'),('valeria','Valeria','Perspectiva crítica y de evidencia'),('karla','Karla','Perspectiva creativa y pedagógica'),('andres','Andrés','Perspectiva práctica y aplicada'),('juan','Juan','Perspectiva técnica y verificable'),('monica','Mónica','Perspectiva de síntesis y comunicación'),('julia','Julia','Perspectiva de evaluación y metacognición'),('idsanna','IDsanna','Supervisión y síntesis de las perspectivas')
on conflict(id) do nothing;

create index if not exists document_chunks_subject_idx on public.document_chunks(subject_id);
create index if not exists messages_conversation_idx on public.messages(conversation_id,created_at);

alter table public.profiles enable row level security; alter table public.subjects enable row level security; alter table public.subject_members enable row level security;
alter table public.documents enable row level security; alter table public.document_chunks enable row level security; alter table public.conversations enable row level security; alter table public.messages enable row level security;
alter table public.credit_accounts enable row level security; alter table public.credit_ledger enable row level security; alter table public.agent_profiles enable row level security;

drop policy if exists profiles_self on public.profiles; create policy profiles_self on public.profiles for all using (id=auth.uid()) with check(id=auth.uid());
drop policy if exists subjects_member_read on public.subjects; create policy subjects_member_read on public.subjects for select using (owner_id=auth.uid() or exists(select 1 from public.subject_members m where m.subject_id=id and m.user_id=auth.uid()));
drop policy if exists subjects_owner_write on public.subjects; create policy subjects_owner_write on public.subjects for all using(owner_id=auth.uid()) with check(owner_id=auth.uid());
drop policy if exists members_self on public.subject_members; create policy members_self on public.subject_members for select using(user_id=auth.uid() or exists(select 1 from public.subjects s where s.id=subject_id and s.owner_id=auth.uid()));
drop policy if exists documents_member on public.documents; create policy documents_member on public.documents for select using(owner_id=auth.uid() or exists(select 1 from public.subject_members m where m.subject_id=subject_id and m.user_id=auth.uid()));
drop policy if exists chunks_member on public.document_chunks; create policy chunks_member on public.document_chunks for select using(exists(select 1 from public.subject_members m where m.subject_id=subject_id and m.user_id=auth.uid()) or exists(select 1 from public.subjects s where s.id=subject_id and s.owner_id=auth.uid()));
drop policy if exists conversations_self on public.conversations; create policy conversations_self on public.conversations for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists messages_self on public.messages; create policy messages_self on public.messages for all using(user_id=auth.uid()) with check(user_id=auth.uid());
drop policy if exists credit_self on public.credit_accounts; create policy credit_self on public.credit_accounts for select using(user_id=auth.uid());
drop policy if exists ledger_self on public.credit_ledger; create policy ledger_self on public.credit_ledger for select using(user_id=auth.uid());
drop policy if exists agents_read on public.agent_profiles; create policy agents_read on public.agent_profiles for select using(true);

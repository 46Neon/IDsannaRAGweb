-- Group roles, profile media and learning analytics primitives.
create table if not exists public.study_group_members (id uuid primary key default gen_random_uuid(), group_id uuid not null references public.study_groups(id) on delete cascade, user_id uuid not null references auth.users(id) on delete cascade, role text not null check(role in ('admin','moderator','student')), created_at timestamptz not null default now(), unique(group_id,user_id));
alter table public.study_groups add column if not exists unit text;
alter table public.study_groups add column if not exists description text;
alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists bio text;
alter table public.profiles add column if not exists avatar_url text;
alter table public.profiles add column if not exists cover_url text;
create table if not exists public.learning_metrics (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, subject_id uuid references public.subjects(id) on delete cascade, metric text not null, value numeric not null default 0, metadata jsonb not null default '{}'::jsonb, recorded_at timestamptz not null default now());
create index if not exists learning_metrics_user_time_idx on public.learning_metrics(user_id,recorded_at desc);
alter table public.study_group_members enable row level security; alter table public.learning_metrics enable row level security;
drop policy if exists group_members_self on public.study_group_members; create policy group_members_self on public.study_group_members for select using(user_id=auth.uid() or exists(select 1 from public.study_groups g where g.id=group_id and g.owner_id=auth.uid()));
drop policy if exists group_members_admin on public.study_group_members; create policy group_members_admin on public.study_group_members for all using(exists(select 1 from public.study_groups g where g.id=group_id and g.owner_id=auth.uid())) with check(exists(select 1 from public.study_groups g where g.id=group_id and g.owner_id=auth.uid()));
drop policy if exists learning_metrics_owner on public.learning_metrics; create policy learning_metrics_owner on public.learning_metrics for all using(user_id=auth.uid()) with check(user_id=auth.uid());

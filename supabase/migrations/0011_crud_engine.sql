-- High-capacity CRUD lifecycle: soft delete, optimistic versioning and audit trail.
alter table public.subjects add column if not exists status text not null default 'active' check(status in ('active','archived','deleted'));
alter table public.subjects add column if not exists version integer not null default 1;
alter table public.subjects add column if not exists updated_at timestamptz not null default now();
create table if not exists public.crud_audit_log (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, entity text not null, entity_id uuid not null, operation text not null check(operation in ('create','update','archive','restore','delete')), version integer, before_data jsonb, after_data jsonb, created_at timestamptz not null default now());
create index if not exists crud_audit_entity_idx on public.crud_audit_log(entity,entity_id,created_at desc);
alter table public.crud_audit_log enable row level security;
drop policy if exists crud_audit_owner on public.crud_audit_log; create policy crud_audit_owner on public.crud_audit_log for select using(user_id=auth.uid());
create or replace function public.touch_subject() returns trigger language plpgsql security invoker as $$ begin new.updated_at=now(); new.version=old.version+1; return new; end $$;
drop trigger if exists subjects_touch on public.subjects; create trigger subjects_touch before update on public.subjects for each row execute function public.touch_subject();

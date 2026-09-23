-- Endurecimiento no destructivo del backend. Verificar primero en una rama/proyecto de prueba.
create or replace function public.touch_updated_at() returns trigger language plpgsql as $$ begin new.updated_at=now(); return new; end; $$;
drop trigger if exists profiles_touch on public.profiles; create trigger profiles_touch before update on public.profiles for each row execute function public.touch_updated_at();
drop trigger if exists subjects_touch on public.subjects; create trigger subjects_touch before update on public.subjects for each row execute function public.touch_updated_at();

create or replace function public.bootstrap_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing; insert into public.credit_accounts(user_id,balance) values(new.id,1000) on conflict(user_id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users; create trigger on_auth_user_created after insert on auth.users for each row execute function public.bootstrap_user();

create or replace function public.add_subject_owner() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.subject_members(subject_id,user_id,role) values(new.id,new.owner_id,'owner') on conflict do nothing; return new; end; $$;
drop trigger if exists subject_owner_membership on public.subjects; create trigger subject_owner_membership after insert on public.subjects for each row execute function public.add_subject_owner();

-- Write policies are limited to the owner; Edge Functions perform processing transitions.
drop policy if exists documents_owner_insert on public.documents; create policy documents_owner_insert on public.documents for insert with check(owner_id=auth.uid() and exists(select 1 from public.subjects s where s.id=subject_id and s.owner_id=auth.uid()));
drop policy if exists documents_owner_update on public.documents; create policy documents_owner_update on public.documents for update using(owner_id=auth.uid()) with check(owner_id=auth.uid());
drop policy if exists conversations_subject_member on public.conversations; create policy conversations_subject_member on public.conversations for insert with check(user_id=auth.uid() and exists(select 1 from public.subject_members m where m.subject_id=subject_id and m.user_id=auth.uid()));

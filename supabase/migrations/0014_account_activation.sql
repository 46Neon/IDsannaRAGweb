alter table public.profiles add column if not exists username text;
alter table public.profiles add column if not exists account_active boolean not null default false;
alter table public.profiles add column if not exists terms_version text;
alter table public.profiles add column if not exists activated_at timestamptz;
create unique index if not exists profiles_username_unique on public.profiles(lower(username)) where username is not null;
create or replace function public.activate_account_after_consent() returns trigger language plpgsql security definer set search_path=public as $$ begin update public.profiles set username=coalesce(new.metadata->>'username',username),account_active=true,terms_version='1.0',activated_at=now() where id=new.user_id; return new; end $$;
drop trigger if exists activate_profile_after_consent on public.user_consents; create trigger activate_profile_after_consent after insert on public.user_consents for each row execute function public.activate_account_after_consent();

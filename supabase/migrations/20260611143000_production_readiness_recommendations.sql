-- ThreatLens AI production-readiness recommendations
-- Generated: 2026-06-11
--
-- Review before applying. This migration changes privileges and RLS policies.
-- It does not drop indexes automatically; duplicate-index cleanup is listed
-- at the bottom as commented SQL.

begin;

-- ==================================================
-- 1. Security fixes
-- ==================================================

-- Remove all direct API table privileges from unauthenticated users.
revoke all privileges on table
  public.profiles,
  public.threat_analyses,
  public.assets,
  public.threats,
  public.dread_scores,
  public.reports,
  public.analysis_history,
  public.user_activity
from anon;

-- Keep normal authenticated DML for PostgREST/RLS, but remove schema-management
-- privileges that client roles should not need.
revoke truncate, trigger, references on table
  public.profiles,
  public.threat_analyses,
  public.assets,
  public.threats,
  public.dread_scores,
  public.reports,
  public.analysis_history,
  public.user_activity
from authenticated;

-- Trigger-only functions should not be directly executable by API roles.
revoke execute on function public.set_updated_at() from anon, authenticated;
revoke execute on function public.dread_scores_set_totals_and_risk() from anon, authenticated;
revoke execute on function public.handle_new_user() from anon, authenticated;
revoke execute on function public.rls_auto_enable() from anon, authenticated;

-- Repair existing auth/profile drift.
insert into public.profiles (id, full_name)
select u.id, coalesce(u.raw_user_meta_data ->> 'full_name', '')
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- ==================================================
-- 2. Performance fixes: RLS init-plan optimization
-- ==================================================

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
for select to authenticated
using (id = (select auth.uid()));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
for insert to authenticated
with check (id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

drop policy if exists profiles_delete_own on public.profiles;
create policy profiles_delete_own on public.profiles
for delete to authenticated
using (id = (select auth.uid()));

drop policy if exists threat_analyses_select_own on public.threat_analyses;
create policy threat_analyses_select_own on public.threat_analyses
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists threat_analyses_insert_own on public.threat_analyses;
create policy threat_analyses_insert_own on public.threat_analyses
for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists threat_analyses_update_own on public.threat_analyses;
create policy threat_analyses_update_own on public.threat_analyses
for update to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

drop policy if exists threat_analyses_delete_own on public.threat_analyses;
create policy threat_analyses_delete_own on public.threat_analyses
for delete to authenticated
using (user_id = (select auth.uid()));

drop policy if exists user_activity_select_own on public.user_activity;
create policy user_activity_select_own on public.user_activity
for select to authenticated
using (user_id = (select auth.uid()));

drop policy if exists user_activity_insert_own on public.user_activity;
create policy user_activity_insert_own on public.user_activity
for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists assets_select_own_analysis on public.assets;
create policy assets_select_own_analysis on public.assets
for select to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = assets.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists assets_insert_own_analysis on public.assets;
create policy assets_insert_own_analysis on public.assets
for insert to authenticated
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = assets.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists assets_update_own_analysis on public.assets;
create policy assets_update_own_analysis on public.assets
for update to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = assets.analysis_id
      and ta.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = assets.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists assets_delete_own_analysis on public.assets;
create policy assets_delete_own_analysis on public.assets
for delete to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = assets.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists threats_select_own_analysis on public.threats;
create policy threats_select_own_analysis on public.threats
for select to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = threats.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists threats_insert_own_analysis on public.threats;
create policy threats_insert_own_analysis on public.threats
for insert to authenticated
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = threats.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists threats_update_own_analysis on public.threats;
create policy threats_update_own_analysis on public.threats
for update to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = threats.analysis_id
      and ta.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = threats.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists threats_delete_own_analysis on public.threats;
create policy threats_delete_own_analysis on public.threats
for delete to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = threats.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists reports_select_own_analysis on public.reports;
create policy reports_select_own_analysis on public.reports
for select to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = reports.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists reports_insert_own_analysis on public.reports;
create policy reports_insert_own_analysis on public.reports
for insert to authenticated
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = reports.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists reports_update_own_analysis on public.reports;
create policy reports_update_own_analysis on public.reports
for update to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = reports.analysis_id
      and ta.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = reports.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists reports_delete_own_analysis on public.reports;
create policy reports_delete_own_analysis on public.reports
for delete to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = reports.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists analysis_history_select_own_analysis on public.analysis_history;
create policy analysis_history_select_own_analysis on public.analysis_history
for select to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = analysis_history.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists analysis_history_insert_own_analysis on public.analysis_history;
create policy analysis_history_insert_own_analysis on public.analysis_history
for insert to authenticated
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = analysis_history.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists analysis_history_update_own_analysis on public.analysis_history;
create policy analysis_history_update_own_analysis on public.analysis_history
for update to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = analysis_history.analysis_id
      and ta.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = analysis_history.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists analysis_history_delete_own_analysis on public.analysis_history;
create policy analysis_history_delete_own_analysis on public.analysis_history
for delete to authenticated
using (
  exists (
    select 1
    from public.threat_analyses ta
    where ta.id = analysis_history.analysis_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists dread_scores_select_own_threat on public.dread_scores;
create policy dread_scores_select_own_threat on public.dread_scores
for select to authenticated
using (
  exists (
    select 1
    from public.threats t
    join public.threat_analyses ta on ta.id = t.analysis_id
    where t.id = dread_scores.threat_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists dread_scores_insert_own_threat on public.dread_scores;
create policy dread_scores_insert_own_threat on public.dread_scores
for insert to authenticated
with check (
  exists (
    select 1
    from public.threats t
    join public.threat_analyses ta on ta.id = t.analysis_id
    where t.id = dread_scores.threat_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists dread_scores_update_own_threat on public.dread_scores;
create policy dread_scores_update_own_threat on public.dread_scores
for update to authenticated
using (
  exists (
    select 1
    from public.threats t
    join public.threat_analyses ta on ta.id = t.analysis_id
    where t.id = dread_scores.threat_id
      and ta.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1
    from public.threats t
    join public.threat_analyses ta on ta.id = t.analysis_id
    where t.id = dread_scores.threat_id
      and ta.user_id = (select auth.uid())
  )
);

drop policy if exists dread_scores_delete_own_threat on public.dread_scores;
create policy dread_scores_delete_own_threat on public.dread_scores
for delete to authenticated
using (
  exists (
    select 1
    from public.threats t
    join public.threat_analyses ta on ta.id = t.analysis_id
    where t.id = dread_scores.threat_id
      and ta.user_id = (select auth.uid())
  )
);

-- ==================================================
-- 3. Trigger fixes
-- ==================================================

drop trigger if exists handle_new_user_trigger on auth.users;
create trigger handle_new_user_trigger
after insert on auth.users
for each row execute function public.handle_new_user();

-- ==================================================
-- 4. Function fixes
-- ==================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = pg_catalog
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''))
  on conflict (id) do nothing;

  return new;
exception
  when others then
    raise log 'handle_new_user failed for auth user id=%', new.id;
    return new;
end;
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.dread_scores_set_totals_and_risk()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
declare
  v_total integer;
begin
  v_total :=
    new.damage +
    new.reproducibility +
    new.exploitability +
    new.affected_users +
    new.discoverability;

  new.total_score := v_total;
  new.risk_level := case
    when v_total between 0 and 10 then 'Low'
    when v_total between 11 and 25 then 'Medium'
    when v_total between 26 and 40 then 'High'
    when v_total between 41 and 50 then 'Critical'
    else 'Low'
  end;

  return new;
end;
$$;

-- ==================================================
-- 5. Index fixes
-- ==================================================

-- Keep FK-supporting indexes. The duplicate cleanup below is intentionally
-- commented out because index removal should be reviewed after checking real
-- query traffic and maintenance windows.

-- drop index concurrently if exists public.idx_analysis_history_analysis_id;
-- drop index concurrently if exists public.idx_assets_analysis_id;
-- drop index concurrently if exists public.idx_dread_scores_threat_id;
-- drop index concurrently if exists public.idx_reports_analysis_id;
-- drop index concurrently if exists public.threat_analyses_user_id_idx;
-- drop index concurrently if exists public.idx_threats_analysis_id;
-- drop index concurrently if exists public.idx_threats_asset_id;

commit;

-- Manual console action:
-- Enable Supabase Auth leaked password protection:
-- https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

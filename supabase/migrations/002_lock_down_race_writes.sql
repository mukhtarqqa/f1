alter table public.races enable row level security;

do $$
declare
  existing_policy record;
begin
  for existing_policy in
    select policyname
    from pg_policies
    where schemaname = 'public' and tablename = 'races'
  loop
    execute format('drop policy %I on public.races', existing_policy.policyname);
  end loop;
end
$$;

create policy "catalog is readable"
  on public.races for select to anon, authenticated
  using (true);

create policy "admins manage races"
  on public.races for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

revoke insert, update, delete on public.races from public, anon, authenticated;
grant select on public.races to anon, authenticated;
grant insert, update, delete on public.races to authenticated;

-- Enable database change delivery over Supabase Realtime WebSockets.
-- Existing SELECT and admin-write RLS policies remain in force.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public' and tablename = 'races'
  ) then
    alter publication supabase_realtime add table public.races;
  end if;
end $$;

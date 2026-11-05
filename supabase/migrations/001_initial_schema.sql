-- Run this file in Supabase SQL Editor. The app talks to PostgreSQL through
-- Supabase REST (PostgREST); never put a PostgreSQL connection string in Flutter.

create table if not exists public.circuits (
  id text primary key,
  name text not null,
  country text not null,
  city text not null,
  length_km double precision not null,
  turns_count integer not null
);

create table if not exists public.teams (
  id text primary key,
  name text not null,
  base_country text not null,
  power_unit text not null,
  points integer not null default 0,
  championships integer not null default 0,
  color_hex bigint not null
);

create table if not exists public.drivers (
  id text primary key,
  team_id text not null references public.teams(id) on delete cascade,
  name text not null,
  code text not null,
  number integer not null,
  country text not null,
  points integer not null default 0,
  podiums integer not null default 0
);

create table if not exists public.races (
  id text primary key,
  circuit_id text not null references public.circuits(id) on delete restrict,
  name text not null,
  country text not null,
  circuit text not null,
  date text not null,
  round integer not null,
  laps integer not null default 56,
  is_completed boolean not null default false,
  winner_driver_id text references public.drivers(id) on delete set null
);

create table if not exists public.reminders (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  race_id text not null references public.races(id) on delete cascade,
  title text not null,
  advance_minutes integer not null,
  notes text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.favorites (
  id text primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  target_type text not null,
  target_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, target_type, target_id)
);

alter table public.circuits enable row level security;
alter table public.teams enable row level security;
alter table public.drivers enable row level security;
alter table public.races enable row level security;
alter table public.reminders enable row level security;
alter table public.favorites enable row level security;

-- Reference data is readable to app clients. Only trusted admins (a
-- server-assigned app_metadata claim) may mutate the shared race calendar.
drop policy if exists "catalog is readable" on public.circuits;
create policy "catalog is readable" on public.circuits for select to anon, authenticated using (true);
drop policy if exists "catalog is readable" on public.teams;
create policy "catalog is readable" on public.teams for select to anon, authenticated using (true);
drop policy if exists "catalog is readable" on public.drivers;
create policy "catalog is readable" on public.drivers for select to anon, authenticated using (true);
drop policy if exists "catalog is readable" on public.races;
create policy "catalog is readable" on public.races for select to anon, authenticated using (true);
drop policy if exists "admins manage races" on public.races;
create policy "admins manage races" on public.races for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "users manage own reminders" on public.reminders;
create policy "users manage own reminders" on public.reminders for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "users manage own favorites" on public.favorites;
create policy "users manage own favorites" on public.favorites for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

grant select on public.circuits, public.teams, public.drivers, public.races to anon, authenticated;
grant insert, update, delete on public.races to authenticated;
grant select, insert, update, delete on public.reminders, public.favorites to authenticated;

-- Seed reference data (demo calendar, not a verified live F1 feed).
insert into public.circuits (id, name, country, city, length_km, turns_count) values
  ('albert_park', 'Albert Park Circuit', 'Австралия', 'Мельбурн', 5.278, 14),
  ('suzuka', 'Suzuka International Racing Course', 'Жапония', 'Сузука', 5.807, 18),
  ('monaco_track', 'Circuit de Monaco', 'Монако', 'Монте-Карло', 3.337, 19),
  ('cota', 'Circuit of the Americas', 'АҚШ', 'Остин', 5.513, 20),
  ('hermanos', 'Autódromo Hermanos Rodríguez', 'Мексика', 'Мехико', 4.304, 17),
  ('interlagos', 'Autódromo José Carlos Pace', 'Бразилия', 'Сан-Паулу', 4.309, 15),
  ('las_vegas', 'Las Vegas Strip Circuit', 'АҚШ', 'Лас-Вегас', 6.201, 17),
  ('lusail', 'Lusail International Circuit', 'Катар', 'Лусаил', 5.419, 16),
  ('yas_marina', 'Yas Marina Circuit', 'БАӘ', 'Абу-Даби', 5.281, 16)
on conflict (id) do nothing;

insert into public.teams (id, name, base_country, power_unit, points, championships, color_hex) values
  ('red_bull', 'Red Bull Racing', 'Ұлыбритания', 'Honda RBPT', 520, 6, 4281758150),
  ('ferrari', 'Scuderia Ferrari', 'Италия', 'Ferrari', 480, 16, 4293394464),
  ('mclaren', 'McLaren F1 Team', 'Ұлыбритания', 'Mercedes', 435, 8, 4294934528),
  ('mercedes', 'Mercedes-AMG PETRONAS', 'Германия', 'Mercedes', 391, 8, 4280808658),
  ('aston_martin', 'Aston Martin Aramco', 'Ұлыбритания', 'Mercedes', 237, 0, 4280457585)
on conflict (id) do nothing;

insert into public.drivers (id, team_id, name, code, number, country, points, podiums) values
  ('ver', 'red_bull', 'Max Verstappen', 'VER', 1, 'Нидерланд', 286, 18),
  ('nor', 'mclaren', 'Lando Norris', 'NOR', 4, 'Ұлыбритания', 270, 16),
  ('lec', 'ferrari', 'Charles Leclerc', 'LEC', 16, 'Монако', 237, 14),
  ('pia', 'mclaren', 'Oscar Piastri', 'PIA', 81, 'Австралия', 210, 11),
  ('sai', 'ferrari', 'Carlos Sainz', 'SAI', 55, 'Испания', 186, 9),
  ('ham', 'mercedes', 'Lewis Hamilton', 'HAM', 44, 'Ұлыбритания', 171, 8)
on conflict (id) do nothing;

insert into public.races (id, circuit_id, name, country, circuit, date, round, laps, is_completed, winner_driver_id) values
  ('australia', 'albert_park', 'Австралия Гран-приі', 'Австралия', 'Albert Park', '15–17 НАУР', 1, 58, true, 'sai'),
  ('japan', 'suzuka', 'Жапония Гран-приі', 'Жапония', 'Suzuka International Racing Course', '05–07 СӘУ', 2, 53, true, 'ver'),
  ('monaco', 'monaco_track', 'Монако Гран-приі', 'Монако', 'Circuit de Monaco', '24–26 МАМ', 3, 78, true, 'lec'),
  ('usa', 'cota', 'АҚШ Гран-приі', 'АҚШ', 'Circuit of the Americas, Austin', '23–25 ҚАЗ', 4, 56, false, null),
  ('mexico', 'hermanos', 'Мексика Гран-приі', 'Мексика', 'Autódromo Hermanos Rodríguez', '30 ҚАЗ – 01 ҚАР', 5, 71, false, null),
  ('brazil', 'interlagos', 'Сан-Паулу Гран-приі', 'Бразилия', 'Interlagos', '06–08 ҚАР', 6, 71, false, null),
  ('vegas', 'las_vegas', 'Лас-Вегас Гран-приі', 'АҚШ', 'Las Vegas Street Circuit', '19–21 ҚАР', 7, 50, false, null),
  ('qatar', 'lusail', 'Катар Гран-приі', 'Катар', 'Lusail International Circuit', '27–29 ҚАР', 8, 57, false, null),
  ('abudhabi', 'yas_marina', 'Абу-Даби Гран-приі', 'БАӘ', 'Yas Marina Circuit', '04–06 ЖЕЛ', 9, 58, false, null)
on conflict (id) do nothing;

"""Read official F1 tables and produce a reviewable, transactional SQL import.

This tool never connects to Supabase or embeds database credentials.
Install requests and beautifulsoup4 to fetch; --from-snapshot works offline.
"""

import argparse
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from datetime import date, datetime
import json
import os
from pathlib import Path
import re
import time

ROOT = Path(__file__).resolve().parents[1]
BASE = 'https://www.formula1.com'
YEAR = 2026
SNAPSHOT = ROOT / 'supabase/data/season_2026.json'
SQL = ROOT / 'supabase/migrations/004_current_2026_season.sql'

# Preserve IDs already used by favorites, reminders and QR codes.
# Unavailable turn counts are represented by 0, not invented from a circuit map.
CIRCUITS = {
    'australia': ('albert_park', 'Albert Park Circuit', 'Австралия', 'Мельбурн', 14),
    'china': ('shanghai', 'Shanghai International Circuit', 'Қытай', 'Шанхай', 0),
    'japan': ('suzuka', 'Suzuka International Racing Course', 'Жапония', 'Сузука', 18),
    'miami': ('miami', 'Miami International Autodrome', 'АҚШ', 'Майами', 0),
    'canada': ('gilles_villeneuve', 'Circuit Gilles-Villeneuve', 'Канада', 'Монреаль', 0),
    'monaco': ('monaco_track', 'Circuit de Monaco', 'Монако', 'Монте-Карло', 19),
    'barcelona-catalunya': ('barcelona', 'Circuit de Barcelona-Catalunya', 'Испания', 'Барселона', 0),
    'austria': ('red_bull_ring', 'Red Bull Ring', 'Австрия', 'Шпильберг', 0),
    'great-britain': ('silverstone', 'Silverstone Circuit', 'Ұлыбритания', 'Сильверстоун', 0),
    'belgium': ('spa', 'Circuit de Spa-Francorchamps', 'Бельгия', 'Спа', 0),
    'hungary': ('hungaroring', 'Hungaroring', 'Мажарстан', 'Модьород', 0),
    'netherlands': ('zandvoort', 'Circuit Zandvoort', 'Нидерланд', 'Зандворт', 0),
    'italy': ('monza', 'Autodromo Nazionale Monza', 'Италия', 'Монца', 0),
    'spain': ('madring', 'MADRING', 'Испания', 'Мадрид', 0),
    'azerbaijan': ('baku', 'Baku City Circuit', 'Әзербайжан', 'Баку', 0),
    'bahrain': ('sepang', 'Sepang International Circuit', 'Малайзия', 'Сепанг', 0),
    'singapore': ('marina_bay', 'Marina Bay Street Circuit', 'Сингапур', 'Сингапур', 0),
    'united-states': ('cota', 'Circuit of the Americas', 'АҚШ', 'Остин', 20),
    'mexico': ('hermanos', 'Autódromo Hermanos Rodríguez', 'Мексика', 'Мехико', 17),
    'brazil': ('interlagos', 'Autódromo José Carlos Pace', 'Бразилия', 'Сан-Паулу', 15),
    'las-vegas': ('las_vegas', 'Las Vegas Strip Circuit', 'АҚШ', 'Лас-Вегас', 17),
    'qatar': ('lusail', 'Lusail International Circuit', 'Катар', 'Лусаил', 16),
    'abu-dhabi': ('yas_marina', 'Yas Marina Circuit', 'БАӘ', 'Абу-Даби', 16),
}
RACE_IDS = {'united-states': 'usa', 'las-vegas': 'vegas', 'abu-dhabi': 'abudhabi'}
TEAMS = {
    'Mercedes': ('mercedes', '27F4D2'),
    'Ferrari': ('ferrari', 'E80020'),
    'Red Bull Racing': ('red_bull', '3671C6'),
    'McLaren': ('mclaren', 'FF8000'),
    'Racing Bulls': ('racing_bulls', '6692FF'),
    'Alpine': ('alpine', 'FF87BC'),
    'Haas F1 Team': ('haas', 'B6BABD'),
    'Audi': ('audi', 'F50537'),
    'Williams': ('williams', '1868DB'),
    'Aston Martin': ('aston_martin', '229971'),
    'Cadillac': ('cadillac', 'AAAAAD'),
}
MONTHS = {'Mar': 'НАУР', 'May': 'МАМ', 'Jun': 'МАУ', 'Jul': 'ШІЛ',
          'Aug': 'ТАМ', 'Sep': 'ҚЫР', 'Oct': 'ҚАЗ', 'Nov': 'ҚАР', 'Dec': 'ЖЕЛ'}


def clean(node):
    return node.get_text(' ', strip=True).replace('\xa0', ' ')


def fetch(path):
    import requests
    from bs4 import BeautifulSoup
    cache_dir = Path(os.environ.get('F1_CACHE_DIR', ROOT / 'build/f1_source_cache'))
    cache = cache_dir / (path.strip('/').replace('/', '_') + '.html')
    if cache.exists() and time.time() - cache.stat().st_mtime < 900:
        html = cache.read_text(encoding='utf-8')
    else:
        response = requests.get(BASE + path, timeout=30)
        response.raise_for_status()
        html = response.text
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(html, encoding='utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    # SVG title elements add accessibility names to text table cells.
    for svg in soup.select('svg'):
        svg.decompose()
    return soup


def rows(soup):
    return [tr.find_all('td') for tr in soup.select('table tr') if tr.find('td')]


def driver_identity(cell):
    text = clean(cell)
    match = re.fullmatch(r'(.+?)\s*([A-Z]{3})', text)
    if not match:
        raise ValueError(f'Unexpected driver name: {text}')
    return match.group(1).strip(), match.group(2)


def calendar_dates(label):
    # Official weekend labels: 06 - 08 Mar, or 30 Oct - 01 Nov.
    m = re.search(r'(\d{2})(?:\s+([A-Z][a-z]{2}))?\s*-\s*(\d{2})\s+([A-Z][a-z]{2})', label)
    if not m:
        raise ValueError(f'Unexpected calendar dates: {label}')
    a, am, b, bm = m.groups()
    am = am or bm
    start = datetime.strptime(f'{YEAR} {am} {a}', '%Y %b %d').date()
    end = datetime.strptime(f'{YEAR} {bm} {b}', '%Y %b %d').date()
    display = f'{a}–{b} {MONTHS[bm]}' if am == bm else f'{a} {MONTHS[am]} – {b} {MONTHS[bm]}'
    return start, end, display


def collect(as_of):
    paths = [f'/en/results/{YEAR}/drivers', f'/en/results/{YEAR}/team',
             f'/en/results/{YEAR}/races', f'/en/racing/{YEAR}', '/en/teams']
    with ThreadPoolExecutor(max_workers=6) as pool:
        drivers_page, teams_page, results_page, calendar, team_index = list(pool.map(fetch, paths))
        result_links = {normalize_slug(tds[0].find('a')['href'].split('/')[-2]): tds[0].find('a')['href']
                        for tds in rows(results_page)}
        race_tiles = {}
        for a in calendar.select(f'a[href^="/en/racing/{YEAR}/"]'):
            label = clean(a)
            if re.match(r'^ROUND \d+ ', label):
                race_tiles[normalize_slug(a['href'].split('/')[-1])] = (a['href'], label)
        team_links = {a['href'] for a in team_index.select('a[href^="/en/teams/"]')}
        print(f'Fetching details: {len(race_tiles)} races, {len(result_links)} results, {len(team_links)} teams', flush=True)
        requested = sorted(set(result_links.values()) | {v[0] for v in race_tiles.values()} | team_links)
        pages = dict(zip(requested, pool.map(fetch, requested)))

    teams = []
    for tds in rows(teams_page):
        position, name, points = map(clean, tds)
        team_id, color = TEAMS[name]
        slug = {'red_bull': 'red-bull-racing', 'racing_bulls': 'racing-bulls',
                'aston_martin': 'aston-martin'}.get(team_id, team_id)
        page = pages.get('/en/teams/' + slug)
        if page is None:
            # Haas uses /haas; fail rather than silently fabricate metadata.
            raise ValueError(f'No team profile for {name}; available: {team_links}')
        text = clean(page)
        base = re.search(r' Base (.+?) Team Chief ', text).group(1)
        power = re.search(r' Power Unit (.+?) (?:Reserve Driver|First Team Entry)', text).group(1)
        titles = int(re.search(r' World Championships (\d+)', text).group(1))
        teams.append(dict(id=team_id, name=name, base_country=base, power_unit=power,
                          points=int(points), championships=titles, color_hex=int('FF' + color, 16),
                          championship_position=int(position)))

    race_results = []
    numbers = {}
    podiums = Counter()
    for slug, path in result_links.items():
        race_id = RACE_IDS.get(slug, slug.replace('-', '_'))
        for tds in rows(pages[path]):
            position, number = clean(tds[0]), int(clean(tds[1]))
            name, code = driver_identity(tds[2])
            numbers[code] = number
            place = int(position) if position.isdecimal() else None
            if place is not None and place <= 3:
                podiums[code] += 1
            race_results.append(dict(race_id=race_id, driver_id=code.lower(),
                classification_order=len([r for r in race_results if r['race_id'] == race_id]) + 1,
                position=place, status=position, laps=int(clean(tds[4]) or 0),
                time=clean(tds[5]), points=float(clean(tds[6]))))

    drivers = []
    for tds in rows(drivers_page):
        name, code = driver_identity(tds[1])
        drivers.append(dict(id=code.lower(), team_id=TEAMS[clean(tds[3])][0], name=name,
            code=code, number=numbers[code], country=clean(tds[2]), points=int(clean(tds[4])),
            podiums=podiums[code], championship_position=int(clean(tds[0]))))

    races, circuits = [], []
    for slug, (path, label) in race_tiles.items():
        circuit_id, circuit_name, country, city, turns = CIRCUITS[slug]
        start, end, display = calendar_dates(label)
        text = clean(pages[path])
        length = float(re.search(r'Circuit Length ([\d.]+)\s*km', text).group(1))
        laps = int(re.search(r'Number of Laps (\d+)', text).group(1))
        completed = slug in result_links
        if completed and end > as_of:
            raise ValueError('Official source contains results later than the requested snapshot date')
        race_id = RACE_IDS.get(slug, slug.replace('-', '_'))
        winner = next((r['driver_id'] for r in race_results
                       if r['race_id'] == race_id and r['position'] == 1), None)
        if completed and not winner:
            raise ValueError(f'Missing winner for {slug}')
        title = 'Бахрейн Гран-приі (Малайзия)' if slug == 'bahrain' else (
            'Барселона-Каталония Гран-приі' if slug == 'barcelona-catalunya' else (
            'Майами Гран-приі' if slug == 'miami' else (
            'Лас-Вегас Гран-приі' if slug == 'las-vegas' else f'{country} Гран-приі')))
        circuits.append(dict(id=circuit_id, name=circuit_name, country=country, city=city,
                             length_km=length, turns_count=turns))
        races.append(dict(id=race_id, circuit_id=circuit_id, name=title, country=country,
            circuit=circuit_name, date=display, round=int(re.search(r'ROUND (\d+)', label).group(1)),
            laps=laps, is_completed=completed, winner_driver_id=winner))
    races.sort(key=lambda r: r['round'])
    return dict(season=YEAR, as_of=as_of.isoformat(), sources=[BASE + p for p in paths[:4]],
                teams=teams, drivers=drivers, circuits=circuits, races=races, race_results=race_results)


def normalize_slug(slug):
    return {'united-arab-emirates': 'abu-dhabi', 'united-kingdom': 'great-britain'}.get(slug, slug)


def validate(data):
    for table in ['teams', 'drivers', 'circuits', 'races']:
        ids = [r['id'] for r in data[table]]
        assert len(ids) == len(set(ids)), f'Duplicate IDs in {table}'
        assert ids, f'Empty {table}'
    assert len(data['teams']) == 11
    assert len(data['drivers']) >= 22
    team_ids = {t['id'] for t in data['teams']}
    driver_ids = {d['id'] for d in data['drivers']}
    circuit_ids = {c['id'] for c in data['circuits']}
    race_ids = {r['id'] for r in data['races']}
    assert [r['round'] for r in data['races']] == list(range(1, len(data['races']) + 1))
    assert all(d['team_id'] in team_ids and d['points'] >= 0 for d in data['drivers'])
    assert all(r['circuit_id'] in circuit_ids for r in data['races'])
    assert all(not r['is_completed'] or r['winner_driver_id'] in driver_ids for r in data['races'])
    assert all(r['race_id'] in race_ids and r['driver_id'] in driver_ids for r in data['race_results'])
    keys = [(r['race_id'], r['driver_id']) for r in data['race_results']]
    assert len(keys) == len(set(keys))
    for race in data['races']:
        results = [r for r in data['race_results'] if r['race_id'] == race['id']]
        assert bool(results) == race['is_completed']
        assert not results or [r['classification_order'] for r in results] == list(range(1, len(results) + 1))
    assert sum(d['podiums'] for d in data['drivers']) == 3 * sum(r['is_completed'] for r in data['races'])


def literal(value):
    if value is None:
        return 'null'
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + value.replace("'", "''") + "'"


def upsert(table, records, keys=('id',)):
    columns = list(records[0])
    values = ',\n'.join('  (' + ', '.join(literal(row[c]) for c in columns) + ')' for row in records)
    updates = ',\n  '.join(f'{c} = excluded.{c}' for c in columns if c not in keys)
    return (f'insert into public.{table} ({", ".join(columns)}) values\n{values}\n'
            f'on conflict ({", ".join(keys)}) do update set\n  {updates};\n')


def generate(data):
    validate(data)
    header = f'''-- Official F1 {YEAR} snapshot as of {data['as_of']}.
-- Sources: {', '.join(data['sources'])}
-- Run after 001_initial_schema.sql. Re-running is safe (upsert, no deletions).
-- Existing IDs, favorites and reminders are preserved. No RLS policy is weakened.
-- Team totals are imported independently: penalties can differ from driver totals.
-- podiums = Grand Prix podiums this season; sprint points are included in standings.
-- turns_count=0 means not supplied by the source for newly added circuits.
begin;

alter table public.drivers add column if not exists championship_position integer;
alter table public.teams add column if not exists championship_position integer;

create table if not exists public.race_results (
  race_id text not null references public.races(id) on delete cascade,
  driver_id text not null references public.drivers(id) on delete cascade,
  classification_order integer not null check (classification_order > 0),
  position integer,
  status text not null,
  laps integer not null check (laps >= 0),
  time text not null,
  points numeric not null check (points >= 0),
  primary key (race_id, driver_id)
);
alter table public.race_results enable row level security;
drop policy if exists "race results are readable" on public.race_results;
create policy "race results are readable" on public.race_results
  for select to anon, authenticated using (true);
grant select on public.race_results to anon, authenticated;

'''
    sql = header
    for table in ['circuits', 'teams', 'drivers', 'races']:
        sql += upsert(table, data[table]) + '\n'
    sql += upsert('race_results', data['race_results'], ('race_id', 'driver_id'))
    sql += '\ncommit;\n'
    SQL.write_text(sql, encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--as-of', type=date.fromisoformat)
    parser.add_argument('--from-snapshot', action='store_true')
    args = parser.parse_args()
    if args.from_snapshot:
        data = json.loads(SNAPSHOT.read_text(encoding='utf-8'))
    else:
        if args.as_of is None:
            parser.error('--as-of YYYY-MM-DD is required when fetching')
        data = collect(args.as_of)
        validate(data)
        SNAPSHOT.parent.mkdir(parents=True, exist_ok=True)
        SNAPSHOT.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    generate(data)
    print(f"Validated {len(data['teams'])} teams, {len(data['drivers'])} drivers, "
          f"{len(data['races'])} races, {len(data['race_results'])} classified results ({data['as_of']}).")
    print(f'Written {SQL.relative_to(ROOT)}')


if __name__ == '__main__':
    main()

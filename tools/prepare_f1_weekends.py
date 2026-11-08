"""Build the 2026 weekend asset from cached official F1 event pages."""

import base64
from datetime import datetime
import json
import re

from bs4 import BeautifulSoup

from prepare_f1_2026 import CIRCUITS, RACE_IDS, ROOT, YEAR, normalize_slug

# Published after the cached event page was collected on 5 November.
BRAZIL_RESULTS = {
    'Practice 1': 'practice/1',
    'Practice 2': 'practice/2',
    'Practice 3': 'practice/3',
    'Qualifying': 'qualifying',
}


def read_weekend(path):
    html = path.read_text(encoding='utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    timestamps = set(re.findall(r'\d{4}-\d\d-\d\dT\d\d:\d\d:00\.000Z', html))
    sessions = []
    for row in soup.select('li[data-f1rd-a7s-context]'):
        time = row.find('time')
        if time is None:
            continue
        context = json.loads(base64.b64decode(row['data-f1rd-a7s-context']))
        day = row.find('span', recursive=False).get_text(' ', strip=True)
        start = datetime.strptime(f'{YEAR} {day} {time.get_text(strip=True)}', '%Y %d %b %H:%M')
        utc = start.isoformat() + '.000Z'
        if utc not in timestamps:
            raise ValueError(f'Unverified UTC time {utc} in {path.name}')
        result = row.select_one('a[data-f1rd-a7s-click="race_session_results_click"]')
        result_path = result['href'] if result else None
        if result_path and not result_path.startswith(f'/en/results/{YEAR}/races/'):
            raise ValueError(f'Unexpected results path: {result_path}')
        sessions.append({'name': context['eventType'], 'start': utc, 'result': result_path})
    if sum(session['name'] == 'Race' for session in sessions) != 1:
        raise ValueError(f'Expected one race session in {path.name}')
    return sorted(sessions, key=lambda session: session['start'])


def main():
    cache = ROOT / 'build/f1_source_cache'
    weekends = {}
    for path in sorted(cache.glob(f'en_racing_{YEAR}_*.html')):
        slug = path.stem.removeprefix(f'en_racing_{YEAR}_')
        key = normalize_slug(slug)
        if key not in CIRCUITS:
            continue
        race_id = RACE_IDS.get(key, key.replace('-', '_'))
        weekends[race_id] = {'slug': slug, 'sessions': read_weekend(path)}
        if slug == 'brazil':
            for session in weekends[race_id]['sessions']:
                suffix = BRAZIL_RESULTS.get(session['name'])
                if suffix and session['result'] is None:
                    session['result'] = f'/en/results/{YEAR}/races/1299/brazil/{suffix}'
    snapshot = json.loads((ROOT / 'supabase/data/season_2026.json').read_text(encoding='utf-8'))
    if set(weekends) != {race['id'] for race in snapshot['races']}:
        raise ValueError('Weekend pages do not cover the season snapshot')
    asset = ROOT / 'assets/f1_weekends_2026.json'
    asset.parent.mkdir(exist_ok=True)
    asset.write_text(json.dumps(weekends, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{len(weekends)} weekends, {sum(len(w["sessions"]) for w in weekends.values())} sessions')


if __name__ == '__main__':
    main()

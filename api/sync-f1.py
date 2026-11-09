import json
import logging
import os
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler

import psycopg
import requests

from tools.prepare_f1_2026 import collect, upsert, validate


def sync():
    os.environ['F1_CACHE_DIR'] = '/tmp/f1-source-cache'
    with psycopg.connect(os.environ['F1_DATABASE_URL'], connect_timeout=10) as conn:
        if not conn.execute('select pg_try_advisory_xact_lock(20261109)').fetchone()[0]:
            return 409, {'error': 'busy'}

        data = collect(datetime.now(timezone.utc).date())
        validate(data)
        completed = {row['id'] for row in data['races'] if row['is_completed']}
        existing = conn.execute(
            'select id from public.races where is_completed and id = any(%s)',
            ([row['id'] for row in data['races']],),
        ).fetchall()
        if any(race_id not in completed for (race_id,) in existing):
            return 409, {'error': 'incomplete_source'}

        for table in ('circuits', 'teams', 'drivers', 'races'):
            conn.execute(upsert(table, data[table]))
        for race_id in completed:
            conn.execute('delete from public.race_results where race_id = %s', (race_id,))
        if data['race_results']:
            conn.execute(upsert('race_results', data['race_results'], ('race_id', 'driver_id')))
        return 200, {'completed': len(completed)}


class handler(BaseHTTPRequestHandler):
    def respond(self, status, body):
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(json.dumps(body).encode())

    def do_POST(self):
        authorization = self.headers.get('Authorization', '')
        if not authorization.startswith('Bearer '):
            self.respond(401, {'error': 'sign_in_required'})
            return
        try:
            user = requests.get(
                os.environ['SUPABASE_URL'].rstrip('/') + '/auth/v1/user',
                headers={
                    'Authorization': authorization,
                    'apikey': os.environ['SUPABASE_PUBLISHABLE_KEY'],
                },
                timeout=10,
            )
            if user.status_code in (401, 403):
                self.respond(401, {'error': 'sign_in_required'})
                return
            user.raise_for_status()
            if user.json().get('app_metadata', {}).get('role') != 'admin':
                self.respond(403, {'error': 'admin_required'})
                return
            status, body = sync()
        except Exception as error:
            logging.error('F1 sync failed (%s)', type(error).__name__)
            status, body = 502, {'error': 'sync_failed'}
        self.respond(status, body)

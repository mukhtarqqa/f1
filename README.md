# F1 Tracker

Для запуска нужны Flutter SDK, Chrome и проект Supabase.

Если база ещё не настроена, выполни SQL-файлы из папки `supabase/migrations` в Supabase SQL Editor по порядку, с `001` по `004`. Включи вход по email в Supabase Auth.

Из корня репозитория запусти:

```powershell
flutter pub get
.\run_chrome.ps1 -SupabaseUrl https://YOUR_PROJECT.supabase.co -SupabaseKey YOUR_PUBLIC_KEY
```

Используй публичный ключ Supabase (publishable или anon). Приложение откроется в Chrome на `http://localhost:5173`. Если параметры уже заданы в локальном `.vscode/launch.json` или в переменных `SUPABASE_URL` и `SUPABASE_ANON_KEY`, достаточно команды `.\run_chrome.ps1`.

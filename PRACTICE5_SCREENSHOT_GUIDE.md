# Практикалық жұмыс №5 — скриншот нұсқаулығы

Бұл нұсқаулық 20 тапсырманың әрқайсысына қандай дәлел түсіру керегін көрсетеді. Интерфейс скриншотын тек қосымшадағы нақты экраннан, API скриншотын тек браузердің **DevTools → Network** бөлімінен, код скриншотын редактордан түсіріңіз. Жалған жауаптар, қолмен жасалған макеттер және құпия кілттерді көрсетпеңіз.

## Алдымен жобаны дайындау

1. Supabase SQL Editor-де [`supabase/migrations/001_initial_schema.sql`](supabase/migrations/001_initial_schema.sql), содан кейін [`supabase/migrations/002_lock_down_race_writes.sql`](supabase/migrations/002_lock_down_race_writes.sql) миграцияларын ретімен орындаңыз. Екінші миграция `races` кестесіндегі бұрыннан қалған кең саясаттарды өшіріп, жазуды тек әкімшіге қалдырады.
2. Supabase Authentication ішінде Email provider-ін қосып, тест пайдаланушы жасаңыз.
3. `races` кестесіне POST/PATCH/DELETE жасау үшін тест пайдаланушыға сенімді `app_metadata.role = admin` рөлін әкімшілік жолмен тағайындаңыз. Рөлді қолданба клиентінен қоймаңыз.
4. Жобаны өз Supabase URL және **anon/publishable** кілтімен іске қосыңыз:

   ```powershell
   flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_KEY
   ```

5. Chrome DevTools → **Network** ашып, `rest/v1` деп сүзгіден өткізіңіз. Сұрау мысалын, HTTP әдісін және status code-ты бір кадрға сыйдыруға тырысыңыз. Скриншотта `apikey`, `Authorization`, access/refresh token, пароль, жеке email сияқты құпия мәндер көрінбесін.
6. Скриншоттарды ретімен `screenshots/01-...png` атауымен сақтаңыз.

## 20 тапсырмаға арналған скриншоттар

| № | Тапсырма | Нені түсіру керек |
|---|---|---|
| 1 | REST API таңдау/құжаттамасын зерттеу | Supabase жобасындағы **API Docs → REST API** бетіндегі PostgREST құжаттамасы немесе Supabase REST API құжаты. Жоба атауы көрінсін, кілттер көрінбесін. |
| 2 | Endpoint тізімін жасау | [`README.md`](README.md) ішіндегі **Endpoint / HTTP әдісі / операция** кестесі. Редакторда Markdown емес, Preview ашып түсірген ыңғайлы. |
| 3 | Әдіс пен операцияны көрсету | README кестесінде `/races` үшін GET/POST/PATCH/DELETE әдістері мен олардың операцияларын бірге көрсетіңіз. |
| 4 | Flutter кітапханасын қосу | [`pubspec.yaml`](pubspec.yaml) ішіндегі `supabase_flutter` жолы; қосымша дәлел ретінде терминалдағы `flutter pub get` сәтті аяқталғанын көрсетіңіз. Бұл жоба PostgREST сұрауларын Supabase Flutter SDK арқылы орындайды. |
| 5 | GET сұрауын орындау | Network-та `GET https://irweckastdpxytvwrlon.supabase.co/rest/v1/races?select=*` сұрауын және сәтті HTTP status code-ын көрсетіңіз. Supabase сұрауына `apikey` header қажет; скриншотта оның мәнін және басқа құпия header-лерді жасырыңыз. |
| 6 | JSON-ды Dart Model-ге түрлендіру | [`f1_models.dart`](lib/data/models/f1_models.dart) файлындағы `F1Race.fromMap` және оның өрістерін оқитын код. |
| 7 | Алынған деректерді интерфейсте көрсету | Қолданбадағы жарыстар күнтізбесі: серверден алынған бірнеше жарыс атауы мен күнін көрсетіңіз. |
| 8 | POST арқылы жаңа ақпарат жіберу | Қосымшада жаңа жарысты сақтаған сәттегі Network POST (upsert) сұрауы және response status. Жарыстың сервер кестесіне қосылғанын Supabase Table Editor-де бөлек растаңыз. Тест пайдаланушыда admin рөлі керек. |
| 9 | PUT/PATCH арқылы өзгерту | Бұл жоба Supabase PostgREST қолданады: ол кесте жазбаларын жаңарту үшін PATCH жібереді, ал PUT әдісін қолдамайды. Network-та `PATCH .../rest/v1/races?id=eq.<id>` сұрауын, request payload пен status code-ты және Supabase кестесіндегі өзгерген өрісті көрсетіңіз. Өзгерістен кейінгі `GET` — күнтізбені қайта жүктеу, жаңарту операциясы емес. |
| 10 | DELETE арқылы жою | Растағаннан кейінгі Network DELETE сұрауы мен status; Supabase кестесінде жазбаның жоғалғанын растаңыз. |
| 11 | `async/await` қолдану | [`f1_repository.dart`](lib/data/repositories/f1_repository.dart) файлындағы `getRaces`, `insertRace`, `updateRace` не `deleteRace` әдістерінің `async`/`await` коды. |
| 12 | Loading күйі | Күнтізбе мәліметі жүктеліп жатқан нақты сәттегі прогресс индикаторы. Көрінбейтіндей тез өтсе, кодтағы `store.isLoading || store.isRaceLoading || _refreshing` шартын түсіріңіз. |
| 13 | Success күйі | Жарыс сақтау/өзгерту/өшіру сәтті біткеннен кейінгі қолданба хабарламасы және соған сәйкес Network response. Хабарлама тек сервер операциясынан кейін шықсын. |
| 14 | Сервер қатесін өңдеу | Кодтан [`f1_repository.dart`](lib/data/repositories/f1_repository.dart) ішіндегі PostgREST/RLS қатесін нақты хабарға түрлендіруді және [`app_store.dart`](lib/data/store/app_store.dart) қатені экран күйіне беруін көрсетіңіз. Қосымшада әкімші емес пайдаланушыға өзгерту батырмалары жоқ. Network қатесін түсіру қажет болса, тек қауіпсіз тест ортада орындаңыз; RLS бұғаттайтындықтан өзгермейтін тест жазбасын қолданыңыз. |
| 15 | Интернет жоқ жағдай | Тест браузерінде DevTools → Network → **Offline** орнатып, жаңадан сұрау жіберіңіз. Қолданбадағы желі қатесін түсіріңіз; сынақтан соң Offline-ды қайта өшіріңіз. |
| 16 | Timeout | Код дәлелі: [`f1_repository.dart`](lib/data/repositories/f1_repository.dart) ішіндегі `Duration(seconds: 15)` және `TimeoutException` өңдеуі. Нақты timeout экрандық дәлелі керек болса, тек қауіпсіз тест ортада >15 секунд кідіретін сұрау қолданыңыз. |
| 17 | Exception өңдеу | Сол repository файлындағы timeout, желі қатесі және жалпы exception-ды `F1DatabaseException` түріне айналдыратын `_request` әдісі. |
| 18 | Серверден келген деректі қосымшада пайдалану | Кодтан дерек жолын көрсетіңіз: [`f1_repository.dart`](lib/data/repositories/f1_repository.dart) сервер JSON-ын `F1Race` моделіне айналдырады → [`app_store.dart`](lib/data/store/app_store.dart) оны `_races` күйінде сақтайды → [`calendar_screen.dart`](lib/features/races/presentation/calendar_screen.dart) `store.races` арқылы экранға шығарады. Осы кодты түсіріңіз; қосымша дәлел ретінде күнтізбедегі жарыстар тізімін көрсетіңіз. Бұл жоба деректерді жергілікті файлға/SQLite-ке емес, жадтағы `AppStore` күйіне сақтайды. |
| 19 | GET/POST/PATCH/DELETE-ті бөлек тексеру | Әр HTTP әдісін жеке-жеке орындап, Network сұрауы/status бар 4 скриншот жасаңыз. Қосымша дәлел ретінде `flutter test` қорытындысы мен [`race_crud_test.dart`](test/race_crud_test.dart) тесттерін түсіріңіз. Тесттегі fake repository тесті сервердегі нақты сұрауды алмастырмайды. |
| 20 | Сервердегі жаңартудың интерфейсте көрінуі | Жарысты өңдегеннен кейін кестедегі жаңа мән және оны қайта жүктегеннен кейін де сол мәннің күнтізбеде қалуы. Қажет болса, қолданба мен Supabase Table Editor-ді екі бөлек скриншотпен көрсетіңіз. |

## Маңызды ескерту

Бұл жоба Supabase-ке нақты сұрауларды **нақты Supabase URL және кілт берілгенде** ғана жібереді. Серверден шынайы GET/POST/PATCH/DELETE дәлелдерін уақытша/жалған кілтпен түсіруге болмайды. `races` кестесіне жазу үшін SQL migration-да көрсетілген admin рөлі қажет.

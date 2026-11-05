"""Prepare read-only source views for evidence screenshots (not app mockups)."""
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VIEW = ROOT / 'build/practice6_source_views'
VIEW.mkdir(parents=True, exist_ok=True)


def section(path, marker=None, count=35):
    lines = (ROOT / path).read_text(encoding='utf-8').splitlines()
    start = next((i for i, line in enumerate(lines) if marker in line), 0) if marker else 0
    selected = lines[start:start + count]
    return f'<h2>{escape(path)}</h2><pre>' + '\n'.join(
        f'<span class="ln">{start + i + 1:4}</span> {escape(line)}' for i, line in enumerate(selected)) + '</pre>'


pages = {
    '03b_login_implementation': ('3 · Реализация входа', [
        ('lib/data/store/app_store.dart', 'Future<AuthActionResult> signIn', 36)]),
    '04b_invalid_credentials_handler': ('4 · Сообщение при неверном email или пароле', [
        ('lib/data/store/app_store.dart', 'String _friendlyAuthError', 20),
        ('lib/features/auth/presentation/auth_screen.dart', 'if (store.authError != null)', 15)]),
    '05b_session_restore_code': ('5–6 · Восстановление сессии', [
        ('lib/data/database/supabase_service.dart', 'static Future<void> initialize', 20),
        ('lib/data/store/app_store.dart', 'final auth = SupabaseService.client.auth', 27)]),
    '07b_logout_implementation': ('7 · Выход из аккаунта', [
        ('lib/data/store/app_store.dart', 'Future<void> signOut()', 23),
        ('lib/features/profile/presentation/profile_screen.dart', 'Future<void> _signOut(', 17)]),
    '08b_profile_binding': ('8 · Связь профиля с данными Supabase Auth', [
        ('lib/data/store/app_store.dart', 'void _updateUser(', 7),
        ('lib/features/profile/presentation/profile_screen.dart', 'store.displayName.isEmpty', 15)]),
    '09_provider_choice': ('9 · Выбран Provider и ChangeNotifier', [
        ('pubspec.yaml', 'dependencies:', 12),
        ('lib/data/store/app_store.dart', 'class AppStore extends ChangeNotifier', 8)]),
    '10_provider_integration': ('10 · Provider подключён к приложению', [
        ('lib/data/store/app_store.dart', 'class StoreScope extends StatelessWidget', 22),
        ('lib/app.dart', 'Widget build(BuildContext context) => AnimatedBuilder', 18)]),
    '12_flutter_dependencies': ('12 · Установленные библиотеки QR и разрешений', [
        ('pubspec.yaml', 'dependencies:', 17),
        ('pubspec.lock', '  mobile_scanner:', 8),
        ('pubspec.lock', '  permission_handler:', 8)]),
    '13c_camera_permission_request': ('13 · Запрос разрешения камеры', [
        ('lib/features/qr_scanner/presentation/qr_scanner_screen.dart', 'void initState()', 20),
        ('lib/features/qr_scanner/presentation/qr_scanner_screen.dart', ': permission.isGranted', 22)]),
    '14_qr_business_logic': ('14 · QR открывает соответствующую гонку', [
        ('lib/features/qr_scanner/presentation/qr_scanner_screen.dart', 'String? parseF1RaceQrCode', 9),
        ('lib/features/qr_scanner/presentation/qr_scanner_screen.dart', 'void _onDetect(', 22),
        ('test/qr_scanner_test.dart', "test('QR payload resolves", 10)]),
    '15c_permission_cases_code': ('15 · Разрешение и запрет камеры', [
        ('lib/features/qr_scanner/presentation/qr_scanner_screen.dart', 'final permanentlyDenied =', 45)]),
    '16c_auth_guard': ('16 · Защита экранов авторизацией', [
        ('lib/core/navigation/app_router.dart', 'final requiresAuth =', 19),
        ('lib/core/navigation/app_router.dart', 'if (!store.isAuthReady)', 21)]),
    '17c_startup_session_check': ('17 · Проверка сессии при запуске', [
        ('lib/features/onboarding/presentation/splash_screen.dart', 'Future<void> _navigate()', 21),
        ('lib/app.dart', 'void initState()', 9)]),
}

for key, (title, parts) in pages.items():
    content = ''.join(section(*part) for part in parts)
    html = f'''<!doctype html><html lang="ru"><meta charset="utf-8">
<title>{escape(title)} — исходный код F1 Tracker</title>
<style>
body{{margin:0;background:#f3f5f8;color:#17212d;font:16px/1.5 Arial,sans-serif}}
main{{max-width:1000px;margin:auto;padding:28px 30px 36px}}
h1{{font-size:25px;line-height:1.3;margin:0 0 8px}}
.note{{color:#46566a;margin:0 0 24px}}h2{{font:15px/1.4 Consolas,monospace;margin:20px 0 8px;color:#254d7a}}
pre{{margin:0;background:white;border:1px solid #d8e0e9;border-radius:8px;padding:18px 12px;
font:13px/1.55 Consolas,monospace;white-space:pre-wrap;overflow-wrap:anywhere}}
.ln{{color:#8c98a7;user-select:none}}footer{{margin-top:20px;color:#56677a;font-size:13px}}
</style><main><h1>{escape(title)}</h1>
<p class="note">Просмотр настоящих файлов проекта. Номера слева — строки исходного файла. Это доказательство реализации в коде, а не результат отдельного запуска.</p>
{content}<footer>F1 Tracker · Практическая работа №6 · Исходный код на момент сбора доказательств</footer></main></html>'''
    (VIEW / (key + '.html')).write_text(html, encoding='utf-8')

(VIEW / 'index.html').write_text('<meta charset="utf-8"><h1>Исходный код F1 Tracker</h1>' + ''.join(
    f'<p><a href="{key}.html">{escape(title)}</a></p>' for key, (title, _) in pages.items()), encoding='utf-8')
print(f'Prepared {len(pages)} source views at {VIEW}')

log = ROOT / 'build/practice6_test_results.txt'
if log.exists():
    report = log.read_text(encoding='utf-8-sig')
    (VIEW / '14b_tests_result.html').write_text('''<!doctype html><meta charset="utf-8">
<title>Проверки регистрации и QR</title><style>
body{font:16px/1.6 Arial;color:#17212d;background:#f3f5f8;margin:32px}
pre{background:white;border:1px solid #d8e0e9;padding:20px;white-space:pre-wrap;font:14px/1.7 Consolas}
h1{font-size:26px}code{font-size:14px}
</style><h1>Проверки регистрации и QR</h1>
<p>Ниже сохранён настоящий вывод Flutter Test. Это автоматические проверки, а не запись физического сканирования камерой.</p>
<p><code>flutter test --no-pub --reporter expanded test/f1_tracker_test.dart test/qr_scanner_test.dart</code></p><pre>'''
        + escape(report) + '</pre>', encoding='utf-8')

OUT = ROOT / 'practice6_evidence'
OUT.mkdir(exist_ok=True)
TASKS = [
    (1, 'Форма Registration', 'Интерфейс формы регистрации.', ['01_registration_form.jpg']),
    (2, 'Валидация обязательных полей', 'Проверены пустые поля, неверный email и пароль короче 6 символов.', ['02a_required_fields_validation.jpg','02b_email_password_validation.jpg']),
    (3, 'Функция Login', 'Форма входа, код signInWithPassword и доступный после выполненного пользователем входа профиль.', ['03a_login_form.jpg','03b_login_implementation.jpg','16a_authenticated_access.jpg']),
    (4, 'Ошибка неверного логина или пароля', 'Реальный ответ Supabase при попытке входа с заведомо неверными тестовыми данными.', ['04a_invalid_login_error.jpg','04b_invalid_credentials_handler.jpg']),
    (5, 'Сохранение сессии', 'Профиль авторизованного пользователя и получение currentUser из сессии Supabase SDK.', ['05_saved_session_profile.jpg','05b_session_restore_code.jpg']),
    (6, 'Проверка сохранённой сессии после запуска', 'После перезагрузки страницы защищённый экран снова доступен без повторного ввода пароля.', ['06_session_restored_after_reload.jpg','05b_session_restore_code.jpg']),
    (7, 'Функция Logout', 'Кнопка выхода, вызов signOut и фактический переход на Login после выхода.', ['07a_logout_button.jpg','07b_logout_implementation.jpg','07c_after_logout.jpg']),
    (8, 'Профиль связан с серверными данными', 'Имя и email загружены из Supabase Auth; показаны личное избранное и напоминание.', ['08_profile_server_data.jpg','08b_profile_binding.jpg']),
    (9, 'Выбор State Management', 'В зависимостях выбран Provider; AppStore наследует ChangeNotifier.', ['09_provider_choice.jpg']),
    (10, 'Внедрение State Management', 'StoreScope создаёт ChangeNotifierProvider, приложение получает и наблюдает состояние.', ['10_provider_integration.jpg']),
    (11, 'Выбор сложной функции устройства', 'QR-сканер доступен из главного экрана F1 Tracker.', ['11_qr_feature_in_app.jpg']),
    (12, 'Установка Flutter-библиотек', 'pubspec.yaml и pubspec.lock подтверждают зависимости mobile_scanner и permission_handler.', ['12_flutter_dependencies.jpg']),
    (13, 'Запрос permission устройства', 'Код запроса Permission.camera.request, активная камера после разрешения и обработка запрета.', ['13a_camera_active.jpg','13b_permission_denied_ui.jpg','13c_camera_permission_request.jpg']),
    (14, 'Связь QR с бизнес-логикой', 'Код разбирает F1RACE:<id>, проверяет наличие гонки и открывает Routes.race. Дополнительно выполнены unit-тесты. Физический переход после поднесения QR к камере отдельно не снимался.', ['14_qr_business_logic.jpg','14b_tests_result.jpg']),
    (15, 'Разрешение предоставлено и запрещено', 'Оба реальных сценария проверены с участием пользователя. В разрешённом сценарии виден видеопоток, в запрещённом — понятное сообщение и повторная проверка.', ['15a_camera_permission_granted.jpg','15b_camera_permission_denied.jpg','15c_permission_cases_code.jpg']),
    (16, 'Доступ с авторизацией и без неё', 'До выхода доступен профиль. После выхода прямое открытие /#/scanner перенаправило на /#/login. Приложен код AuthGuard.', ['16a_authenticated_access.jpg','16b_unauthenticated_redirect.jpg','16c_auth_guard.jpg']),
    (17, 'Повторный запуск и функция устройства', 'Для веб-версии выполнена перезагрузка страницы и повторное открытие QR-сканера: сессия восстановилась, состояние запрета камеры обработано. Это проверка веб-перезапуска; полное закрытие ОС/браузера не выполнялось.', ['17a_session_after_restart.jpg','17b_device_permission_after_restart.jpg','17c_startup_session_check.jpg']),
]

intro = ('Скриншоты к практической работе №6 из документа ec6761ac-43bd-45b4-a130-1766c60e5001.docx. '
         'Нумерация соответствует 17 пунктам документа. Использована работающая веб-версия F1 Tracker. '
         'Снимки приложения показывают реальные состояния, снимки кода — настоящие файлы с номерами строк. '
         'Снимки кода и лог тестов не выдаются за отдельную проверку устройства. '
         'Новый аккаунт не создавался: пользователь самостоятельно выполнил вход. '
         'Разрешение и запрет камеры выбирал пользователь.')
md = ['# Доказательства практической работы №6', '', intro, '']
html = ['<!doctype html><html lang="ru"><meta charset="utf-8"><title>Практическая работа 6 — доказательства</title>',
        '<style>body{font:16px/1.6 Arial,sans-serif;background:#f3f5f8;color:#17212d;margin:0}main{max-width:1120px;margin:auto;padding:28px}h1{font-size:30px}h2{margin-top:36px;font-size:23px}figure{margin:20px 0;background:white;padding:14px;border:1px solid #dae2eb;border-radius:10px}img{max-width:100%;height:auto;display:block;margin:auto}figcaption{margin-top:10px;color:#51657a}nav a{margin-right:16px}a{color:#174f8b}p{max-width:1000px}</style><main>',
        '<h1>Доказательства практической работы №6</h1><p>'+escape(intro)+'</p><nav>',
        ' '.join(f'<a href="#task-{number}">{number}</a>' for number, *_ in TASKS), '</nav>']
for number, title, note, images in TASKS:
    md += [f'## {number}. {title}', '', note, '']
    html += [f'<section id="task-{number}"><h2>{number}. {escape(title)}</h2><p>{escape(note)}</p>']
    for filename in images:
        md += [f'- [{filename}]({filename})']
        html += [f'<figure><a href="{filename}"><img loading="lazy" src="{filename}" alt="{escape(title)}"></a><figcaption>{escape(filename)}</figcaption></figure>']
    md += ['']
    html += ['</section>']
html += ['</main></html>']
(OUT / 'README.md').write_text('\n'.join(md), encoding='utf-8')
(OUT / 'index.html').write_text('\n'.join(html), encoding='utf-8')
print(f'Written index and task mapping at {OUT}')

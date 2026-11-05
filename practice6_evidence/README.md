# Доказательства практической работы №6

Скриншоты к практической работе №6 из документа ec6761ac-43bd-45b4-a130-1766c60e5001.docx. Нумерация соответствует 17 пунктам документа. Использована работающая веб-версия F1 Tracker. Снимки приложения показывают реальные состояния, снимки кода — настоящие файлы с номерами строк. Снимки кода и лог тестов не выдаются за отдельную проверку устройства. Новый аккаунт не создавался: пользователь самостоятельно выполнил вход. Разрешение и запрет камеры выбирал пользователь.

## 1. Форма Registration

Интерфейс формы регистрации.

- [01_registration_form.jpg](01_registration_form.jpg)

## 2. Валидация обязательных полей

Проверены пустые поля, неверный email и пароль короче 6 символов.

- [02a_required_fields_validation.jpg](02a_required_fields_validation.jpg)
- [02b_email_password_validation.jpg](02b_email_password_validation.jpg)

## 3. Функция Login

Форма входа, код signInWithPassword и доступный после выполненного пользователем входа профиль.

- [03a_login_form.jpg](03a_login_form.jpg)
- [03b_login_implementation.jpg](03b_login_implementation.jpg)
- [16a_authenticated_access.jpg](16a_authenticated_access.jpg)

## 4. Ошибка неверного логина или пароля

Реальный ответ Supabase при попытке входа с заведомо неверными тестовыми данными.

- [04a_invalid_login_error.jpg](04a_invalid_login_error.jpg)
- [04b_invalid_credentials_handler.jpg](04b_invalid_credentials_handler.jpg)

## 5. Сохранение сессии

Профиль авторизованного пользователя и получение currentUser из сессии Supabase SDK.

- [05_saved_session_profile.jpg](05_saved_session_profile.jpg)
- [05b_session_restore_code.jpg](05b_session_restore_code.jpg)

## 6. Проверка сохранённой сессии после запуска

После перезагрузки страницы защищённый экран снова доступен без повторного ввода пароля.

- [06_session_restored_after_reload.jpg](06_session_restored_after_reload.jpg)
- [05b_session_restore_code.jpg](05b_session_restore_code.jpg)

## 7. Функция Logout

Кнопка выхода, вызов signOut и фактический переход на Login после выхода.

- [07a_logout_button.jpg](07a_logout_button.jpg)
- [07b_logout_implementation.jpg](07b_logout_implementation.jpg)
- [07c_after_logout.jpg](07c_after_logout.jpg)

## 8. Профиль связан с серверными данными

Имя и email загружены из Supabase Auth; показаны личное избранное и напоминание.

- [08_profile_server_data.jpg](08_profile_server_data.jpg)
- [08b_profile_binding.jpg](08b_profile_binding.jpg)

## 9. Выбор State Management

В зависимостях выбран Provider; AppStore наследует ChangeNotifier.

- [09_provider_choice.jpg](09_provider_choice.jpg)

## 10. Внедрение State Management

StoreScope создаёт ChangeNotifierProvider, приложение получает и наблюдает состояние.

- [10_provider_integration.jpg](10_provider_integration.jpg)

## 11. Выбор сложной функции устройства

QR-сканер доступен из главного экрана F1 Tracker.

- [11_qr_feature_in_app.jpg](11_qr_feature_in_app.jpg)

## 12. Установка Flutter-библиотек

pubspec.yaml и pubspec.lock подтверждают зависимости mobile_scanner и permission_handler.

- [12_flutter_dependencies.jpg](12_flutter_dependencies.jpg)

## 13. Запрос permission устройства

Код запроса Permission.camera.request, активная камера после разрешения и обработка запрета.

- [13a_camera_active.jpg](13a_camera_active.jpg)
- [13b_permission_denied_ui.jpg](13b_permission_denied_ui.jpg)
- [13c_camera_permission_request.jpg](13c_camera_permission_request.jpg)

## 14. Связь QR с бизнес-логикой

Код разбирает F1RACE:<id>, проверяет наличие гонки и открывает Routes.race. Дополнительно выполнены unit-тесты. Физический переход после поднесения QR к камере отдельно не снимался.

- [14_qr_business_logic.jpg](14_qr_business_logic.jpg)
- [14b_tests_result.jpg](14b_tests_result.jpg)

## 15. Разрешение предоставлено и запрещено

Оба реальных сценария проверены с участием пользователя. В разрешённом сценарии виден видеопоток, в запрещённом — понятное сообщение и повторная проверка.

- [15a_camera_permission_granted.jpg](15a_camera_permission_granted.jpg)
- [15b_camera_permission_denied.jpg](15b_camera_permission_denied.jpg)
- [15c_permission_cases_code.jpg](15c_permission_cases_code.jpg)

## 16. Доступ с авторизацией и без неё

До выхода доступен профиль. После выхода прямое открытие /#/scanner перенаправило на /#/login. Приложен код AuthGuard.

- [16a_authenticated_access.jpg](16a_authenticated_access.jpg)
- [16b_unauthenticated_redirect.jpg](16b_unauthenticated_redirect.jpg)
- [16c_auth_guard.jpg](16c_auth_guard.jpg)

## 17. Повторный запуск и функция устройства

Для веб-версии выполнена перезагрузка страницы и повторное открытие QR-сканера: сессия восстановилась, состояние запрета камеры обработано. Это проверка веб-перезапуска; полное закрытие ОС/браузера не выполнялось.

- [17a_session_after_restart.jpg](17a_session_after_restart.jpg)
- [17b_device_permission_after_restart.jpg](17b_device_permission_after_restart.jpg)
- [17c_startup_session_check.jpg](17c_startup_session_check.jpg)

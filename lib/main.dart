import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
    runApp(const F1TrackerApp());
  } catch (error) {
    runApp(SupabaseStartupErrorApp(error: error));
  }
}

class SupabaseStartupErrorApp extends StatelessWidget {
  const SupabaseStartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final details = error.toString().toLowerCase();
    final requestTimedOut =
        details.contains('15 секунд') || details.contains('timeout');
    final noConnection = details.contains('socketexception') ||
        details.contains('failed to fetch') ||
        details.contains('networkerror');

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'F1 Tracker не удалось подключить к Supabase',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    requestTimedOut
                        ? 'Сервер Supabase не ответил за 15 секунд. '
                            'Проверьте интернет-соединение и повторите запуск.'
                        : noConnection
                            ? 'Нет подключения к интернету или серверу Supabase. '
                                'Проверьте сеть и повторите запуск.'
                            : 'Проверьте URL и publishable key Supabase, доступность проекта '
                                'и настройки аутентификации.',
                  ),
                  const SizedBox(height: 16),
                  SelectableText('Детали: $error'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

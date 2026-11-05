import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseService {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static Future<void> initialize() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw StateError(
        'Supabase is not configured. Pass SUPABASE_URL and '
        'SUPABASE_ANON_KEY with --dart-define.',
      );
    }

    await Supabase.initialize(url: _url, publishableKey: _anonKey);
    if (kDebugMode) {
      debugPrint('Connected to Supabase PostgreSQL via PostgREST.');
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}

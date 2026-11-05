import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/supabase_service.dart';
import '../models/f1_models.dart';

enum RaceFilter { all, upcoming, completed }

enum RaceSort { roundAsc, roundDesc, nameAsc, nameDesc }

enum DriverSort { pointsDesc, pointsAsc, nameAsc, podiumsDesc }

class F1DatabaseException implements Exception {
  const F1DatabaseException(this.message, [this.originalError]);
  final String message;
  final Object? originalError;

  @override
  String toString() => 'F1DatabaseException: $message ($originalError)';
}

/// Data access through Supabase PostgREST backed by PostgreSQL.
class F1Repository {
  F1Repository({SupabaseClient? client}) : _providedClient = client;

  static const _requestTimeout = Duration(seconds: 15);
  final SupabaseClient? _providedClient;
  SupabaseClient get _client => _providedClient ?? SupabaseService.client;

  Future<T> _request<T>(
    Future<T> Function() action,
    String errorMessage,
  ) async {
    try {
      return await action().timeout(_requestTimeout);
    } on TimeoutException catch (error) {
      throw F1DatabaseException(
        'Сервер 15 секунд ішінде жауап бермеді. Кейінірек қайталап көріңіз.',
        error,
      );
    } on F1DatabaseException {
      rethrow;
    } on PostgrestException catch (error) {
      final details = [
        if (error.code != null) 'код ${error.code}',
        error.message,
        if (error.details?.toString().isNotEmpty ?? false)
          error.details.toString(),
        if (error.hint?.isNotEmpty ?? false) 'кеңес: ${error.hint}',
      ].join(' — ');
      final message = error.code == '42501'
          ? '$errorMessage: сервер рұқсат бермеді (RLS). $details'
          : '$errorMessage: $details';
      throw F1DatabaseException(message, error);
    } catch (error) {
      final details = error.toString().toLowerCase();
      if (details.contains('socketexception') ||
          details.contains('failed to fetch') ||
          details.contains('networkerror') ||
          details.contains('network request failed')) {
        throw F1DatabaseException(
          'Интернет байланысы жоқ. Байланысты тексеріп, қайта көріңіз.',
          error,
        );
      }
      throw F1DatabaseException(errorMessage, error);
    }
  }

  Future<List<F1Race>> getRaces({
    String query = '',
    RaceFilter filter = RaceFilter.all,
    RaceSort sort = RaceSort.roundAsc,
  }) async {
    return _request(() async {
      var request = _client.from('races').select();
      if (filter == RaceFilter.upcoming) {
        request = request.eq('is_completed', false);
      } else if (filter == RaceFilter.completed) {
        request = request.eq('is_completed', true);
      }
      final (column, ascending, tieColumn, tieAscending) = switch (sort) {
        RaceSort.roundAsc => ('round', true, 'name', true),
        RaceSort.roundDesc => ('round', false, 'name', true),
        RaceSort.nameAsc => ('name', true, 'round', true),
        RaceSort.nameDesc => ('name', false, 'round', true),
      };
      final maps = await request
          .order(column, ascending: ascending)
          .order(tieColumn, ascending: tieAscending);
      var races = maps.map((row) => F1Race.fromMap(row)).toList();
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        races = races
            .where((race) =>
                race.name.toLowerCase().contains(q) ||
                race.country.toLowerCase().contains(q) ||
                race.circuit.toLowerCase().contains(q))
            .toList();
      }
      return races;
    }, 'Жарыстарды оқу кезінде сервер қатесі орын алды.');
  }

  Future<F1Race?> getRaceById(String id) async {
    return _request(() async {
      final row =
          await _client.from('races').select().eq('id', id).maybeSingle();
      return row == null ? null : F1Race.fromMap(row);
    }, 'Жарысты оқу қатесі: $id');
  }

  Future<void> insertRace(F1Race race) async {
    return _request(() async {
      await _client.from('races').upsert(race.toMap());
    }, 'Жарысты қосу қатесі. Сервер рұқсаттарын тексеріңіз.');
  }

  Future<void> updateRace(F1Race race) async {
    return _request(() async {
      final rows = await _client
          .from('races')
          .update(race.toMap())
          .eq('id', race.id)
          .select('id');
      if (rows.isEmpty) {
        throw F1DatabaseException(
          'Жарыс жаңартылмады: жазба табылмады немесе сервер рұқсат бермеді.',
        );
      }
    }, 'Жарысты жаңарту қатесі. Сервер рұқсаттарын тексеріңіз.');
  }

  Future<void> deleteRace(String id) async {
    return _request(() async {
      final rows =
          await _client.from('races').delete().eq('id', id).select('id');
      if (rows.isEmpty) {
        throw F1DatabaseException(
          'Жарыс өшірілмеді: жазба табылмады немесе сервер рұқсат бермеді.',
        );
      }
    }, 'Жарысты өшіру қатесі. Сервер рұқсаттарын тексеріңіз.');
  }

  Future<List<F1Driver>> getDrivers({
    String query = '',
    String? teamId,
    DriverSort sort = DriverSort.pointsDesc,
  }) async {
    try {
      final rows = switch (sort) {
        DriverSort.pointsDesc => await _client
            .from('drivers')
            .select()
            .order('points', ascending: false)
            .order('championship_position')
            .order('name'),
        DriverSort.pointsAsc =>
          await _client.from('drivers').select().order('points').order('name'),
        DriverSort.nameAsc => await _client
            .from('drivers')
            .select()
            .order('name')
            .order('points', ascending: false),
        DriverSort.podiumsDesc => await _client
            .from('drivers')
            .select()
            .order('podiums', ascending: false)
            .order('points', ascending: false),
      };
      var drivers = rows.map((row) => F1Driver.fromMap(row)).toList();
      if (teamId != null && teamId.isNotEmpty) {
        drivers = drivers.where((driver) => driver.teamId == teamId).toList();
      }
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        drivers = drivers
            .where((driver) =>
                driver.name.toLowerCase().contains(q) ||
                driver.code.toLowerCase().contains(q) ||
                driver.country.toLowerCase().contains(q))
            .toList();
      }
      return drivers;
    } catch (e) {
      throw F1DatabaseException('Жүргізушілерді оқу қатесі', e);
    }
  }

  Future<List<F1Team>> getTeams({String query = ''}) async {
    try {
      final rows = await _client
          .from('teams')
          .select()
          .order('points', ascending: false)
            .order('championship_position');
      var teams = rows.map((row) => F1Team.fromMap(row)).toList();
      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        teams = teams
            .where((team) =>
                team.name.toLowerCase().contains(q) ||
                team.powerUnit.toLowerCase().contains(q))
            .toList();
      }
      return teams;
    } catch (e) {
      throw F1DatabaseException('Командаларды оқу қатесі', e);
    }
  }

  Future<List<F1Circuit>> getCircuits() async {
    try {
      final rows = await _client.from('circuits').select().order('name');
      return rows.map((row) => F1Circuit.fromMap(row)).toList();
    } catch (e) {
      throw F1DatabaseException('Трассаларды оқу қатесі', e);
    }
  }

  Future<List<F1Reminder>> getReminders() async {
    try {
      final rows = await _client
          .from('reminders')
          .select()
          .order('created_at', ascending: false);
      return rows.map((row) => F1Reminder.fromMap(row)).toList();
    } catch (e) {
      throw F1DatabaseException('Еске салғыштарды оқу қатесі', e);
    }
  }

  Future<void> insertReminder(F1Reminder reminder) async {
    try {
      await _client.from('reminders').upsert(_reminderData(reminder));
    } catch (e) {
      throw F1DatabaseException('Еске салғышты сақтау қатесі', e);
    }
  }

  Future<void> updateReminder(F1Reminder reminder) => insertReminder(reminder);

  Future<void> deleteReminder(String id) async {
    try {
      await _client.from('reminders').delete().eq('id', id);
    } catch (e) {
      throw F1DatabaseException('Еске салғышты өшіру қатесі', e);
    }
  }

  Map<String, dynamic> _reminderData(F1Reminder reminder) => {
        ...reminder.toMap(),
        'user_id': _currentUserId,
      };

  String get _currentUserId {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw const F1DatabaseException('Пайдаланушы сессиясы табылмады');
    }
    return id;
  }

  Future<Set<String>> getFavoriteRaceIds() async {
    try {
      final rows = await _client
          .from('favorites')
          .select('target_id')
          .eq('target_type', 'race');
      return rows.map((row) => row['target_id'] as String).toSet();
    } catch (e) {
      throw F1DatabaseException('Таңдаулыларды оқу қатесі', e);
    }
  }

  Future<bool> isFavorite(String targetId, {String targetType = 'race'}) async {
    try {
      final row = await _client
          .from('favorites')
          .select('id')
          .eq('target_type', targetType)
          .eq('target_id', targetId)
          .maybeSingle();
      return row != null;
    } catch (e) {
      throw F1DatabaseException('Таңдаулыны тексеру қатесі', e);
    }
  }

  Future<void> toggleFavorite(String targetId,
      {String targetType = 'race'}) async {
    try {
      final existing = await _client
          .from('favorites')
          .select('id')
          .eq('target_type', targetType)
          .eq('target_id', targetId)
          .maybeSingle();
      if (existing != null) {
        await _client.from('favorites').delete().eq('id', existing['id']);
      } else {
        await _client.from('favorites').insert({
          'id': 'fav_${targetId}_${DateTime.now().microsecondsSinceEpoch}',
          'user_id': _currentUserId,
          'target_type': targetType,
          'target_id': targetId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw F1DatabaseException('Таңдаулы күйін өзгерту қатесі', e);
    }
  }

  Future<List<F1RaceResult>> getRaceResults(String raceId) =>
      _request(() async {
        final rows = await _client
            .from('race_results')
            .select()
            .eq('race_id', raceId)
            .order('classification_order');
        return rows.map(F1RaceResult.fromMap).toList();
      }, 'Жарыс нәтижелерін жүктеу сәтсіз аяқталды.');

  Future<void> resetDatabase() async {
    try {
      final userId = _currentUserId;
      await _client.from('favorites').delete().eq('user_id', userId);
      await _client.from('reminders').delete().eq('user_id', userId);
    } catch (e) {
      throw F1DatabaseException('Жеке деректерді тазалау қатесі', e);
    }
  }
}

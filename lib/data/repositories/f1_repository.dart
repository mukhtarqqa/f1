import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/f1_models.dart';

enum RaceFilter { all, upcoming, completed }
enum RaceSort { roundAsc, roundDesc, nameAsc, nameDesc }
enum DriverSort { pointsDesc, pointsAsc, nameAsc, podiumsDesc }

/// Қателерді ұстау және өңдеу класы
class F1DatabaseException implements Exception {
  const F1DatabaseException(this.message, [this.originalError]);
  final String message;
  final Object? originalError;

  @override
  String toString() => 'F1DatabaseException: $message ($originalError)';
}

/// 12. Деректер қорымен жұмыс істейтін Repository қабаты
class F1Repository {
  F1Repository({AppDatabase? db}) : _appDb = db ?? AppDatabase.instance;
  final AppDatabase _appDb;

  Future<Database> get _db => _appDb.database;

  // ==========================================
  // RACES (CRUD, Search, Filter, Sort)
  // ==========================================

  /// 9. Read, 13. Search, 14. Filter, 15. Sort operations for Races
  Future<List<F1Race>> getRaces({
    String query = '',
    RaceFilter filter = RaceFilter.all,
    RaceSort sort = RaceSort.roundAsc,
  }) async {
    try {
      final db = await _db;

      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      // 14. Filter
      if (filter == RaceFilter.upcoming) {
        whereClauses.add('is_completed = 0');
      } else if (filter == RaceFilter.completed) {
        whereClauses.add('is_completed = 1');
      }

      // 15. Multi-parameter Sorting
      String orderBy;
      switch (sort) {
        case RaceSort.roundAsc:
          orderBy = 'round ASC, name ASC';
          break;
        case RaceSort.roundDesc:
          orderBy = 'round DESC, name ASC';
          break;
        case RaceSort.nameAsc:
          orderBy = 'name ASC, round ASC';
          break;
        case RaceSort.nameDesc:
          orderBy = 'name DESC, round ASC';
          break;
      }

      final maps = await db.query(
        'races',
        where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: orderBy,
      );

      var list = maps.map(F1Race.fromMap).toList();

      // 13. Search (Unicode-safe for Kazakh/Cyrillic & Latin)
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((r) =>
                r.name.toLowerCase().contains(q) ||
                r.country.toLowerCase().contains(q) ||
                r.circuit.toLowerCase().contains(q))
            .toList();
      }

      return list;
    } catch (e) {
      throw F1DatabaseException('Жарыстарды оқу кезінде қате орын алды', e);
    }
  }

  Future<F1Race?> getRaceById(String id) async {
    try {
      final db = await _db;
      final maps = await db.query('races', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return F1Race.fromMap(maps.first);
    } catch (e) {
      throw F1DatabaseException('Жарысты табу қатесі: $id', e);
    }
  }

  /// 8. Create race
  Future<void> insertRace(F1Race race) async {
    try {
      final db = await _db;
      await db.insert('races', race.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw F1DatabaseException('Жарысты қосу қатесі', e);
    }
  }

  /// 10. Update race
  Future<void> updateRace(F1Race race) async {
    try {
      final db = await _db;
      final count = await db.update(
        'races',
        race.toMap(),
        where: 'id = ?',
        whereArgs: [race.id],
      );
      if (count == 0) {
        throw F1DatabaseException('Жаңарту үшін жарыс табылмады: ${race.id}');
      }
    } catch (e) {
      throw F1DatabaseException('Жарысты жаңарту қатесі', e);
    }
  }

  /// 11. Delete race
  Future<void> deleteRace(String id) async {
    try {
      final db = await _db;
      await db.delete('races', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw F1DatabaseException('Жарысты өшіру қатесі', e);
    }
  }

  // ==========================================
  // DRIVERS & TEAMS (Read, Filter, Sort, Search)
  // ==========================================

  Future<List<F1Driver>> getDrivers({
    String query = '',
    String? teamId,
    DriverSort sort = DriverSort.pointsDesc,
  }) async {
    try {
      final db = await _db;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (teamId != null && teamId.isNotEmpty) {
        whereClauses.add('team_id = ?');
        whereArgs.add(teamId);
      }

      String orderBy;
      switch (sort) {
        case DriverSort.pointsDesc:
          orderBy = 'points DESC, podiums DESC, name ASC';
          break;
        case DriverSort.pointsAsc:
          orderBy = 'points ASC, name ASC';
          break;
        case DriverSort.nameAsc:
          orderBy = 'name ASC, points DESC';
          break;
        case DriverSort.podiumsDesc:
          orderBy = 'podiums DESC, points DESC';
          break;
      }

      final maps = await db.query(
        'drivers',
        where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: orderBy,
      );

      var list = maps.map(F1Driver.fromMap).toList();
      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((d) =>
                d.name.toLowerCase().contains(q) ||
                d.code.toLowerCase().contains(q) ||
                d.country.toLowerCase().contains(q))
            .toList();
      }
      return list;
    } catch (e) {
      throw F1DatabaseException('Жүргізушілерді оқу қатесі', e);
    }
  }

  Future<List<F1Team>> getTeams({String query = ''}) async {
    try {
      final db = await _db;
      final where = query.trim().isEmpty ? null : '(LOWER(name) LIKE ? OR LOWER(power_unit) LIKE ?)';
      final args = query.trim().isEmpty ? null : ['%${query.trim().toLowerCase()}%', '%${query.trim().toLowerCase()}%'];

      final maps = await db.query(
        'teams',
        where: where,
        whereArgs: args,
        orderBy: 'points DESC, championships DESC',
      );
      return maps.map(F1Team.fromMap).toList();
    } catch (e) {
      throw F1DatabaseException('Командаларды оқу қатесі', e);
    }
  }

  Future<List<F1Circuit>> getCircuits() async {
    try {
      final db = await _db;
      final maps = await db.query('circuits', orderBy: 'name ASC');
      return maps.map(F1Circuit.fromMap).toList();
    } catch (e) {
      throw F1DatabaseException('Трассаларды оқу қатесі', e);
    }
  }

  // ==========================================
  // REMINDERS (CRUD - 8, 9, 10, 11)
  // ==========================================

  Future<List<F1Reminder>> getReminders() async {
    try {
      final db = await _db;
      final maps = await db.query('reminders', orderBy: 'created_at DESC');
      return maps.map(F1Reminder.fromMap).toList();
    } catch (e) {
      throw F1DatabaseException('Еске салғыштарды оқу қатесі', e);
    }
  }

  /// 8. Create reminder
  Future<void> insertReminder(F1Reminder reminder) async {
    try {
      final db = await _db;
      await db.insert('reminders', reminder.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw F1DatabaseException('Еске салғышты сақтау қатесі', e);
    }
  }

  /// 10. Update reminder
  Future<void> updateReminder(F1Reminder reminder) async {
    try {
      final db = await _db;
      final count = await db.update(
        'reminders',
        reminder.toMap(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
      if (count == 0) {
        // Егер жазба табылмаса, жаңасын кірістіреміз
        await insertReminder(reminder);
      }
    } catch (e) {
      throw F1DatabaseException('Еске салғышты өзгерту қатесі', e);
    }
  }

  /// 11. Delete reminder
  Future<void> deleteReminder(String id) async {
    try {
      final db = await _db;
      await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw F1DatabaseException('Еске салғышты өшіру қатесі', e);
    }
  }

  // ==========================================
  // FAVORITES (16. Favorites функциясы)
  // ==========================================

  Future<Set<String>> getFavoriteRaceIds() async {
    try {
      final db = await _db;
      final maps = await db.query('favorites', where: "target_type = 'race'");
      return maps.map((m) => m['target_id'] as String).toSet();
    } catch (e) {
      throw F1DatabaseException('Таңдаулыларды оқу қатесі', e);
    }
  }

  Future<bool> isFavorite(String targetId, {String targetType = 'race'}) async {
    try {
      final db = await _db;
      final maps = await db.query(
        'favorites',
        where: 'target_type = ? AND target_id = ?',
        whereArgs: [targetType, targetId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      throw F1DatabaseException('Таңдаулыны тексеру қатесі', e);
    }
  }

  Future<void> toggleFavorite(String targetId, {String targetType = 'race'}) async {
    try {
      final db = await _db;
      final existing = await db.query(
        'favorites',
        where: 'target_type = ? AND target_id = ?',
        whereArgs: [targetType, targetId],
      );

      if (existing.isNotEmpty) {
        await db.delete(
          'favorites',
          where: 'target_type = ? AND target_id = ?',
          whereArgs: [targetType, targetId],
        );
      } else {
        final fav = F1Favorite(
          id: 'fav_${targetId}_${DateTime.now().millisecondsSinceEpoch}',
          targetType: targetType,
          targetId: targetId,
          createdAt: DateTime.now().toIso8601String(),
        );
        await db.insert('favorites', fav.toMap());
      }
    } catch (e) {
      throw F1DatabaseException('Таңдаулы күйін өзгерту қатесі', e);
    }
  }

  // ==========================================
  // DATABASE RESET / REFRESH
  // ==========================================

  Future<void> resetDatabase() async {
    try {
      await _appDb.resetDatabase();
    } catch (e) {
      throw F1DatabaseException('Деректер қорын тазалау қатесі', e);
    }
  }
}

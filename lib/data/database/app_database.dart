import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/f1_models.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'f1_tracker.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  static void ensurePlatformInitialized() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDatabase() async {
    ensurePlatformInitialized();

    final String dbPath;
    if (kIsWeb) {
      dbPath = _dbName;
    } else {
      final databasesPath = await getDatabasesPath();
      dbPath = p.join(databasesPath, _dbName);
    }

    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. Трассалар кестесі
    await db.execute('''
      CREATE TABLE IF NOT EXISTS circuits (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        city TEXT NOT NULL,
        length_km REAL NOT NULL,
        turns_count INTEGER NOT NULL
      )
    ''');

    // 2. Командалар кестесі
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teams (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        base_country TEXT NOT NULL,
        power_unit TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0,
        championships INTEGER NOT NULL DEFAULT 0,
        color_hex INTEGER NOT NULL
      )
    ''');

    // 3. Жүргізушілер кестесі (Сыртқы кілт: team_id -> teams.id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS drivers (
        id TEXT PRIMARY KEY,
        team_id TEXT NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        number INTEGER NOT NULL,
        country TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0,
        podiums INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
      )
    ''');

    // 4. Жарыстар кестесі (Сыртқы кілттер: circuit_id -> circuits.id, winner_driver_id -> drivers.id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS races (
        id TEXT PRIMARY KEY,
        circuit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        country TEXT NOT NULL,
        circuit TEXT NOT NULL,
        date TEXT NOT NULL,
        round INTEGER NOT NULL,
        laps INTEGER NOT NULL DEFAULT 56,
        is_completed INTEGER NOT NULL DEFAULT 0,
        winner_driver_id TEXT,
        FOREIGN KEY (circuit_id) REFERENCES circuits (id) ON DELETE RESTRICT,
        FOREIGN KEY (winner_driver_id) REFERENCES drivers (id) ON DELETE SET NULL
      )
    ''');

    // 5. Еске салғыштар кестесі (Сыртқы кілт: race_id -> races.id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        race_id TEXT NOT NULL,
        title TEXT NOT NULL,
        advance_minutes INTEGER NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        FOREIGN KEY (race_id) REFERENCES races (id) ON DELETE CASCADE
      )
    ''');

    // 6. Таңдаулылар кестесі
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        id TEXT PRIMARY KEY,
        target_type TEXT NOT NULL,
        target_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedInitialData(DatabaseExecutor db) async {
    final batch = db.batch();

    // 1. Circuits
    const circuits = [
      F1Circuit(id: 'albert_park', name: 'Albert Park Circuit', country: 'Австралия', city: 'Мельбурн', lengthKm: 5.278, turnsCount: 14),
      F1Circuit(id: 'suzuka', name: 'Suzuka International Racing Course', country: 'Жапония', city: 'Сузука', lengthKm: 5.807, turnsCount: 18),
      F1Circuit(id: 'monaco_track', name: 'Circuit de Monaco', country: 'Монако', city: 'Монте-Карло', lengthKm: 3.337, turnsCount: 19),
      F1Circuit(id: 'cota', name: 'Circuit of the Americas', country: 'АҚШ', city: 'Остин', lengthKm: 5.513, turnsCount: 20),
      F1Circuit(id: 'hermanos', name: 'Autódromo Hermanos Rodríguez', country: 'Мексика', city: 'Мехико', lengthKm: 4.304, turnsCount: 17),
      F1Circuit(id: 'interlagos', name: 'Autódromo José Carlos Pace', country: 'Бразилия', city: 'Сан-Паулу', lengthKm: 4.309, turnsCount: 15),
      F1Circuit(id: 'las_vegas', name: 'Las Vegas Strip Circuit', country: 'АҚШ', city: 'Лас-Вегас', lengthKm: 6.201, turnsCount: 17),
      F1Circuit(id: 'lusail', name: 'Lusail International Circuit', country: 'Катар', city: 'Лусаил', lengthKm: 5.419, turnsCount: 16),
      F1Circuit(id: 'yas_marina', name: 'Yas Marina Circuit', country: 'БАӘ', city: 'Абу-Даби', lengthKm: 5.281, turnsCount: 16),
    ];
    for (final c in circuits) {
      batch.insert('circuits', c.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 2. Teams
    const teams = [
      F1Team(id: 'red_bull', name: 'Red Bull Racing', baseCountry: 'Ұлыбритания', powerUnit: 'Honda RBPT', points: 520, championships: 6, colorHex: 0xFF3671C6),
      F1Team(id: 'ferrari', name: 'Scuderia Ferrari', baseCountry: 'Италия', powerUnit: 'Ferrari', points: 480, championships: 16, colorHex: 0xFFE80020),
      F1Team(id: 'mclaren', name: 'McLaren F1 Team', baseCountry: 'Ұлыбритания', powerUnit: 'Mercedes', points: 435, championships: 8, colorHex: 0xFFFF8000),
      F1Team(id: 'mercedes', name: 'Mercedes-AMG PETRONAS', baseCountry: 'Германия', powerUnit: 'Mercedes', points: 391, championships: 8, colorHex: 0xFF27F4D2),
      F1Team(id: 'aston_martin', name: 'Aston Martin Aramco', baseCountry: 'Ұлыбритания', powerUnit: 'Mercedes', points: 237, championships: 0, colorHex: 0xFF229971),
    ];
    for (final t in teams) {
      batch.insert('teams', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 3. Drivers
    const drivers = [
      F1Driver(id: 'ver', teamId: 'red_bull', name: 'Max Verstappen', code: 'VER', number: 1, country: 'Нидерланд', points: 286, podiums: 18),
      F1Driver(id: 'nor', teamId: 'mclaren', name: 'Lando Norris', code: 'NOR', number: 4, country: 'Ұлыбритания', points: 270, podiums: 16),
      F1Driver(id: 'lec', teamId: 'ferrari', name: 'Charles Leclerc', code: 'LEC', number: 16, country: 'Монако', points: 237, podiums: 14),
      F1Driver(id: 'pia', teamId: 'mclaren', name: 'Oscar Piastri', code: 'PIA', number: 81, country: 'Австралия', points: 210, podiums: 11),
      F1Driver(id: 'sai', teamId: 'ferrari', name: 'Carlos Sainz', code: 'SAI', number: 55, country: 'Испания', points: 186, podiums: 9),
      F1Driver(id: 'ham', teamId: 'mercedes', name: 'Lewis Hamilton', code: 'HAM', number: 44, country: 'Ұлыбритания', points: 171, podiums: 8),
    ];
    for (final d in drivers) {
      batch.insert('drivers', d.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 4. Races
    const races = [
      F1Race(id: 'australia', circuitId: 'albert_park', name: 'Австралия Гран-приі', country: 'Австралия', circuit: 'Albert Park', date: '15–17 НАУР • АЯҚТАЛДЫ', round: 1, laps: 58, isCompleted: true, winnerDriverId: 'sai'),
      F1Race(id: 'japan', circuitId: 'suzuka', name: 'Жапония Гран-приі', country: 'Жапония', circuit: 'Suzuka International Racing Course', date: '05–07 СӘУ • АЯҚТАЛДЫ', round: 2, laps: 53, isCompleted: true, winnerDriverId: 'ver'),
      F1Race(id: 'monaco', circuitId: 'monaco_track', name: 'Монако Гран-приі', country: 'Монако', circuit: 'Circuit de Monaco', date: '24–26 МАМ • АЯҚТАЛДЫ', round: 3, laps: 78, isCompleted: true, winnerDriverId: 'lec'),
      F1Race(id: 'usa', circuitId: 'cota', name: 'АҚШ Гран-приі', country: 'АҚШ', circuit: 'Circuit of the Americas, Austin', date: '23–25 ҚАЗ • АЛДАҒЫ', round: 4, laps: 56, isCompleted: false),
      F1Race(id: 'mexico', circuitId: 'hermanos', name: 'Мексика Гран-приі', country: 'Мексика', circuit: 'Autódromo Hermanos Rodríguez', date: '30 ҚАЗ – 01 ҚАР • АЛДАҒЫ', round: 5, laps: 71, isCompleted: false),
      F1Race(id: 'brazil', circuitId: 'interlagos', name: 'Сан-Паулу Гран-приі', country: 'Бразилия', circuit: 'Interlagos', date: '06–08 ҚАР • АЛДАҒЫ', round: 6, laps: 71, isCompleted: false),
      F1Race(id: 'vegas', circuitId: 'las_vegas', name: 'Лас-Вегас Гран-приі', country: 'АҚШ', circuit: 'Las Vegas Street Circuit', date: '19–21 ҚАР • АЛДАҒЫ', round: 7, laps: 50, isCompleted: false),
      F1Race(id: 'qatar', circuitId: 'lusail', name: 'Катар Гран-приі', country: 'Катар', circuit: 'Lusail International Circuit', date: '27–29 ҚАР • АЛДАҒЫ', round: 8, laps: 57, isCompleted: false),
      F1Race(id: 'abudhabi', circuitId: 'yas_marina', name: 'Абу-Даби Гран-приі', country: 'БАӘ', circuit: 'Yas Marina Circuit', date: '04–06 ЖЕЛ • АЛДАҒЫ', round: 9, laps: 58, isCompleted: false),
    ];
    for (final r in races) {
      batch.insert('races', r.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 5. Initial Favorites
    final initialFavorites = [
      F1Favorite(id: 'fav_usa', targetType: 'race', targetId: 'usa', createdAt: DateTime.now().toIso8601String()),
      F1Favorite(id: 'fav_monaco', targetType: 'race', targetId: 'monaco', createdAt: DateTime.now().toIso8601String()),
    ];
    for (final f in initialFavorites) {
      batch.insert('favorites', f.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    // 6. Initial Reminder
    final initialReminder = F1Reminder(
      id: 'rem_usa_1',
      raceId: 'usa',
      title: 'АҚШ Гран-приін өткізіп алмау',
      advanceMinutes: 60,
      notes: 'Негізгі жарыс алдында хабарлау',
      createdAt: DateTime.now().toIso8601String(),
    );
    batch.insert('reminders', initialReminder.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    await batch.commit(noResult: true);
  }

  /// Қосымшаны сынау немесе баптау үшін базаны бастапқы қалпына келтіру
  Future<void> resetDatabase() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites');
      await txn.delete('reminders');
      await txn.delete('races');
      await txn.delete('drivers');
      await txn.delete('teams');
      await txn.delete('circuits');
      await _seedInitialData(txn);
    });
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}

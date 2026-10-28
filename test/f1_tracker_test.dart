import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:f1_tracker/app.dart';
import 'package:f1_tracker/data/database/app_database.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/data/repositories/f1_repository.dart';
import 'package:f1_tracker/data/store/app_store.dart';
import 'package:f1_tracker/features/auth/presentation/auth_screen.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Практикалық жұмыс №4: SQLite & Repository CRUD сынақтары', () {
    late AppDatabase appDb;
    late F1Repository repository;
    late AppStore store;

    setUp(() async {
      appDb = AppDatabase.instance;
      await appDb.resetDatabase();
      repository = F1Repository(db: appDb);
      store = AppStore(repository: repository);
      await store.init();
    });

    test('1-4. 6 Entity құрылымы және бастапқы деректерді оқу (Read)', () async {
      expect(store.races.length, greaterThanOrEqualTo(9));
      expect(store.circuits.length, greaterThanOrEqualTo(9));
      expect(store.teams.length, greaterThanOrEqualTo(5));
      expect(store.drivers.length, greaterThanOrEqualTo(6));
      expect(store.favorites.isNotEmpty, isTrue);
    });

    test('8, 9, 10, 11. Еске салғыштар CRUD (Create, Read, Update, Delete)', () async {
      final initialCount = store.reminders.length;

      // 8. Create
      const reminder = F1Reminder(
        id: 'test_rem_1',
        raceId: 'usa',
        title: 'Тест еске салғыш',
        advanceMinutes: 30,
        notes: 'Сынақ жазбасы',
      );
      await store.saveReminder(reminder);

      expect(store.reminders.length, initialCount + 1);
      final found = store.reminders.firstWhere((r) => r.id == 'test_rem_1');
      expect(found.title, 'Тест еске салғыш');
      expect(found.advanceMinutes, 30);

      // 10. Update
      final updated = found.copyWith(title: 'Жаңартылған еске салғыш', advanceMinutes: 120);
      await store.saveReminder(updated);

      final reloaded = store.reminders.firstWhere((r) => r.id == 'test_rem_1');
      expect(reloaded.title, 'Жаңартылған еске салғыш');
      expect(reloaded.advanceMinutes, 120);

      // 11. Delete
      await store.removeReminder('test_rem_1');
      expect(store.reminders.any((r) => r.id == 'test_rem_1'), isFalse);
      expect(store.reminders.length, initialCount);
    });

    test('13. Жарыстар мен жүргізушілерді іздеу (Search query)', () async {
      // Name / country бойынша іздеу
      final results = await repository.getRaces(query: 'Австралия');
      expect(results.length, 1);
      expect(results.first.country, 'Австралия');

      final emptyResults = await repository.getRaces(query: 'БеймәлімТрасса123');
      expect(emptyResults, isEmpty);

      // Driver search
      final drivers = await repository.getDrivers(query: 'Verstappen');
      expect(drivers.length, 1);
      expect(drivers.first.code, 'VER');
    });

    test('14. Критерийлер бойынша сүзгілеу (Filtering)', () async {
      final upcoming = await repository.getRaces(filter: RaceFilter.upcoming);
      expect(upcoming.every((r) => !r.isCompleted), isTrue);

      final completed = await repository.getRaces(filter: RaceFilter.completed);
      expect(completed.every((r) => r.isCompleted), isTrue);
    });

    test('15. Екі немесе одан көп параметр бойынша сұрыптау (Sorting)', () async {
      // 1) Кезең бойынша өсу ретімен (roundAsc)
      final roundAsc = await repository.getRaces(sort: RaceSort.roundAsc);
      for (int i = 0; i < roundAsc.length - 1; i++) {
        expect(roundAsc[i].round <= roundAsc[i + 1].round, isTrue);
      }

      // 2) Атауы бойынша (nameAsc)
      final nameAsc = await repository.getRaces(sort: RaceSort.nameAsc);
      for (int i = 0; i < nameAsc.length - 1; i++) {
        expect(nameAsc[i].name.compareTo(nameAsc[i + 1].name) <= 0, isTrue);
      }

      // 3) Жүргізушілерді ұпай бойынша сұрыптау
      final driversPoints = await repository.getDrivers(sort: DriverSort.pointsDesc);
      for (int i = 0; i < driversPoints.length - 1; i++) {
        expect(driversPoints[i].points >= driversPoints[i + 1].points, isTrue);
      }
    });

    test('16. Таңдаулылар (Favorites) қосу, тексеру және өшіру', () async {
      expect(store.isFavorite('mexico'), isFalse);

      await store.toggleFavorite('mexico');
      expect(store.isFavorite('mexico'), isTrue);

      await store.toggleFavorite('mexico');
      expect(store.isFavorite('mexico'), isFalse);
    });

    test('20. Локалды деректердің сақталуы (Persistence verification)', () async {
      // Жаңа жазба қосу
      const reminder = F1Reminder(
        id: 'persisted_rem_1',
        raceId: 'monaco',
        title: 'Тұрақты еске салғыш',
        advanceMinutes: 15,
      );
      await repository.insertReminder(reminder);

      // Жаңа Repository және AppStore данасын ашып, деректердің қордан оқылуын тексеру
      final secondRepo = F1Repository(db: appDb);
      final secondStore = AppStore(repository: secondRepo);
      await secondStore.init();

      expect(secondStore.reminders.any((r) => r.id == 'persisted_rem_1'), isTrue);
    });
  });

  group('UI Виджет сынақтары', () {
    testWidgets('splash экраннан onboarding-ке бағыттау', (tester) async {
      await tester.pumpWidget(const F1TrackerApp());
      expect(find.text('Формула-1. Барлығы бір жерде.'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(find.text('Жарысты өткізіп алма'), findsOneWidget);
    });

    testWidgets('login экраны валидация хабарламаларын шығарады', (tester) async {
      final store = AppStore();
      await tester.pumpWidget(StoreScope(
        store: store,
        child: const MaterialApp(
          home: AuthScreen(mode: AuthMode.login),
        ),
      ));
      await tester.enterText(find.byType(TextFormField).first, 'wrong-email');
      await tester.ensureVisible(find.text('Кіру').first);
      await tester.tap(find.text('Кіру').first);
      await tester.pumpAndSettle();
      expect(find.text('Email мекенжайы дұрыс емес'), findsOneWidget);
      expect(find.text('Құпиясөз бос болмауы керек'), findsOneWidget);
    });
  });
}

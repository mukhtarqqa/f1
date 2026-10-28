import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/app.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/features/auth/presentation/auth_screen.dart';
import 'package:f1_tracker/data/store/app_store.dart';

void main() {
  test('favorites can be added and removed', () {
    final store = AppStore();
    expect(store.isFavorite('usa'), isTrue);
    store.toggleFavorite('usa');
    expect(store.isFavorite('usa'), isFalse);
    store.toggleFavorite('usa');
    expect(store.isFavorite('usa'), isTrue);
  });

  test('reminders support create, edit and delete', () {
    final store = AppStore();
    const a = F1Reminder(id: '1', title: 'Жарыс', raceId: 'usa', advanceMinutes: 60);
    store.saveReminder(a);
    expect(store.reminders, hasLength(1));
    store.saveReminder(a.copyWith(title: 'Өзгертілді'));
    expect(store.reminders.single.title, 'Өзгертілді');
    store.removeReminder('1');
    expect(store.reminders, isEmpty);
  });

  testWidgets('splash navigates into onboarding', (tester) async {
    await tester.pumpWidget(const F1TrackerApp());
    expect(find.text('Формула-1. Барлығы бір жерде.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();
    expect(find.text('Жарысты өткізіп алма'), findsOneWidget);
  });

  testWidgets('login shows friendly validation errors', (tester) async {
    final store = AppStore();
    await tester.pumpWidget(StoreScope(store: store, child: const MaterialApp(
      home: AuthScreen(mode: AuthMode.login),
    )));
    await tester.enterText(find.byType(TextFormField).first, 'wrong-email');
    await tester.ensureVisible(find.text('Кіру').first);
    await tester.tap(find.text('Кіру').first);
    await tester.pumpAndSettle();
    expect(find.text('Email мекенжайы дұрыс емес'), findsOneWidget);
    expect(find.text('Құпиясөз бос болмауы керек'), findsOneWidget);
  });
}


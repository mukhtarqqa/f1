import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/data/store/app_store.dart';
import 'package:f1_tracker/features/auth/presentation/auth_screen.dart';

void main() {
  testWidgets('login form shows validation messages', (tester) async {
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

  testWidgets('registration form validates every required field',
      (tester) async {
    final store = AppStore();
    await tester.pumpWidget(StoreScope(
      store: store,
      child: const MaterialApp(
        home: AuthScreen(mode: AuthMode.register),
      ),
    ));

    await tester.ensureVisible(find.text('Тіркелу').first);
    await tester.tap(find.text('Тіркелу').first);
    await tester.pumpAndSettle();

    expect(find.text('Атыңызды енгізіңіз'), findsOneWidget);
    expect(find.text('Email енгізіңіз'), findsOneWidget);
    expect(find.text('Құпиясөз бос болмауы керек'), findsOneWidget);
  });

  testWidgets('store can be read from an event callback without listening',
      (tester) async {
    final store = AppStore();
    await tester.pumpWidget(StoreScope(
      store: store,
      child: MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                expect(StoreScope.of(context, listen: false), same(store)),
            child: const Text('Read store'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Read store'));
    await tester.pump();
  });
}

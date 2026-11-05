import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/data/repositories/f1_repository.dart';
import 'package:f1_tracker/data/store/app_store.dart';
import 'package:f1_tracker/features/results/presentation/results_screen.dart';

void main() {
  testWidgets('race results use the selected race and actual awarded points',
      (tester) async {
    final repository = _ResultsRepository([
      _result('ver', 1, 12.5),
      _result('ham', 2, 9),
      _result('ant', 3, 7.5),
    ]);
    final store = AppStore(repository: repository);
    addTearDown(store.dispose);
    await tester.pumpWidget(StoreScope(
        store: store,
        child: const MaterialApp(
          home: ResultsScreen(raceId: 'mexico'),
        )));
    await tester.pumpAndSettle();
    expect(repository.requestedRace, 'mexico');
    expect(find.text('12.5 PTS'), findsNWidgets(2));
    expect(find.text('VER'), findsNWidgets(2));
    expect(find.text('25 PTS'), findsNothing);
  });

  testWidgets('an upcoming race does not fabricate finishing results',
      (tester) async {
    final store = AppStore(repository: _ResultsRepository([]));
    addTearDown(store.dispose);
    await tester.pumpWidget(StoreScope(
        store: store,
        child: const MaterialApp(
          home: ResultsScreen(raceId: 'brazil'),
        )));
    await tester.pumpAndSettle();
    expect(find.text('Нәтижелер әлі жарияланбаған'), findsOneWidget);
    expect(find.text('25 PTS'), findsNothing);
  });

  test('unclassified drivers retain their status and zero points', () {
    final result = F1RaceResult.fromMap({
      'race_id': 'australia',
      'driver_id': 'alo',
      'classification_order': 18,
      'position': null,
      'status': 'NC',
      'laps': 21,
      'time': 'DNF',
      'points': 0,
    });
    expect(result.position, isNull);
    expect(result.status, 'NC');
    expect(result.pointsLabel, '0');
  });
}

F1RaceResult _result(String driver, int position, num points) => F1RaceResult(
      raceId: 'mexico',
      driverId: driver,
      classificationOrder: position,
      position: position,
      status: '$position',
      laps: 71,
      time: '+1.0s',
      points: points,
    );

class _ResultsRepository extends F1Repository {
  _ResultsRepository(this.results);
  final List<F1RaceResult> results;
  String? requestedRace;

  @override
  Future<List<F1RaceResult>> getRaceResults(String raceId) async {
    requestedRace = raceId;
    return results;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/data/repositories/f1_repository.dart';
import 'package:f1_tracker/data/store/app_store.dart';

void main() {
  late _FakeF1Repository repository;
  late AppStore store;

  setUp(() {
    repository = _FakeF1Repository();
    store = AppStore(repository: repository);
  });

  tearDown(() {
    store.dispose();
  });

  test('POST create refreshes the local race list', () async {
    final race = _race('new-race');

    expect(await store.saveRace(race), isTrue);
    expect(store.races, [race]);
    expect(repository.insertCount, 1);
  });

  test('PATCH update changes the race shown in the local list', () async {
    final original = _race('race-1');
    final changed = original.copyWith(name: 'Updated Grand Prix');
    repository.races.add(original);

    expect(await store.updateRace(changed), isTrue);
    expect(store.races.single.name, 'Updated Grand Prix');
    expect(repository.updateCount, 1);
  });

  test('DELETE removes the race from the refreshed local list', () async {
    repository.races.add(_race('race-1'));

    expect(await store.deleteRace('race-1'), isTrue);
    expect(store.races, isEmpty);
    expect(repository.deleteCount, 1);
  });

  test('a server error is surfaced instead of a success result', () async {
    repository.failure = const F1DatabaseException('Permission denied');

    expect(await store.saveRace(_race('denied')), isFalse);
    expect(store.errorMessage, contains('Permission denied'));
    expect(store.isRaceLoading, isFalse);
  });
}

F1Race _race(String id, {String name = 'Test Grand Prix'}) => F1Race(
      id: id,
      circuitId: 'cota',
      name: name,
      country: 'United States',
      circuit: 'Circuit of the Americas',
      date: '12 October',
      round: 10,
    );

class _FakeF1Repository extends F1Repository {
  final List<F1Race> races = [];
  int insertCount = 0;
  int updateCount = 0;
  int deleteCount = 0;
  F1DatabaseException? failure;

  void _throwIfFailed() {
    if (failure case final error?) throw error;
  }

  @override
  Future<List<F1Race>> getRaces({
    String query = '',
    RaceFilter filter = RaceFilter.all,
    RaceSort sort = RaceSort.roundAsc,
  }) async {
    _throwIfFailed();
    return List.of(races);
  }

  @override
  Future<void> insertRace(F1Race race) async {
    _throwIfFailed();
    insertCount++;
    races.add(race);
  }

  @override
  Future<void> updateRace(F1Race race) async {
    _throwIfFailed();
    updateCount++;
    final index = races.indexWhere((item) => item.id == race.id);
    if (index >= 0) races[index] = race;
  }

  @override
  Future<void> deleteRace(String id) async {
    _throwIfFailed();
    deleteCount++;
    races.removeWhere((race) => race.id == id);
  }
}

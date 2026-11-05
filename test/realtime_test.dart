import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/data/database/race_realtime.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/data/repositories/f1_repository.dart';
import 'package:f1_tracker/data/store/app_store.dart';

void main() {
  test('live changes refresh UI; reconnect fetches missed changes', () async {
    final transport = _Transport();
    final repository = _Repository();
    final store = _SignedInStore(repository, transport);
    addTearDown(store.dispose);
    store.startRealtime();
    transport.connection(LiveConnection.connected);
    await Future<void>.delayed(Duration.zero);
    expect(store.races.single.name, 'Original');

    repository.name = 'Live update';
    transport.change();
    await Future<void>.delayed(Duration.zero);
    expect(store.races.single.name, 'Live update');

    transport.connection(LiveConnection.reconnecting);
    expect(store.liveConnection, LiveConnection.reconnecting);
    expect(store.races.single.name, 'Live update');
    repository.name = 'Changed while offline';
    transport.connection(LiveConnection.connected);
    await Future<void>.delayed(Duration.zero);
    expect(store.races.single.name, 'Changed while offline');
  });

  test('old in-flight results cannot overwrite a newer live update', () async {
    final repository = _Repository();
    final store = _SignedInStore(repository, _Transport());
    addTearDown(store.dispose);
    final pending = Completer<List<F1Race>>();
    repository.pending = pending;
    final oldRequest = store.refreshRaces();
    repository.pending = null;
    repository.name = 'Newest';
    await store.refreshRaces();
    pending.complete([]);
    await oldRequest;
    expect(store.races.single.name, 'Newest');
  });

  test('stopped subscriptions ignore late events and release transport',
      () async {
    final transport = _Transport();
    final repository = _Repository();
    final store = _SignedInStore(repository, transport);
    store.startRealtime();
    await store.stopRealtime();
    transport.change();
    transport.connection(LiveConnection.connected);
    await Future<void>.delayed(Duration.zero);
    expect(store.liveConnection, LiveConnection.stopped);
    expect(repository.reads, 0);
    store.dispose();
    expect(transport.stops, 2);
  });

  test('failed resync keeps cached races and exposes a retryable error',
      () async {
    final repository = _Repository();
    final store = _SignedInStore(repository, _Transport());
    addTearDown(store.dispose);
    await store.refreshRaces();
    repository.fail = true;
    await store.refreshRaces();
    expect(store.races.single.name, 'Original');
    expect(store.errorMessage, contains('offline'));
    repository.fail = false;
    await store.refreshRaces();
    expect(store.errorMessage, isNull);
  });
}

class _SignedInStore extends AppStore {
  _SignedInStore(F1Repository repository, RaceRealtime realtime)
      : super(repository: repository, realtime: realtime);

  @override
  bool get isAuthenticated => true;
}

class _Transport implements RaceRealtime {
  late void Function() change;
  late void Function(LiveConnection) connection;
  int stops = 0;

  @override
  void start({
    required void Function() onChange,
    required void Function(LiveConnection) onConnection,
  }) {
    change = onChange;
    connection = onConnection;
    onConnection(LiveConnection.connecting);
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

class _Repository extends F1Repository {
  String name = 'Original';
  bool fail = false;
  int reads = 0;
  Completer<List<F1Race>>? pending;

  @override
  Future<List<F1Race>> getRaces({
    String query = '',
    RaceFilter filter = RaceFilter.all,
    RaceSort sort = RaceSort.roundAsc,
  }) async {
    reads++;
    if (pending != null) return pending!.future;
    if (fail) throw Exception('offline');
    return [
      F1Race(
          id: 'usa',
          circuitId: 'cota',
          name: name,
          country: 'USA',
          circuit: 'COTA',
          date: 'October',
          round: 4)
    ];
  }
}

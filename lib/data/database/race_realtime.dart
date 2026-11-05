import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

enum LiveConnection { stopped, connecting, connected, reconnecting }

/// Transport kept separate from Provider so lifecycle and resync can be tested.
abstract class RaceRealtime {
  void start({
    required void Function() onChange,
    required void Function(LiveConnection) onConnection,
  });
  Future<void> stop();
}

class SupabaseRaceRealtime implements RaceRealtime {
  RealtimeChannel? _channel;

  @override
  void start({
    required void Function() onChange,
    required void Function(LiveConnection) onConnection,
  }) {
    if (_channel != null) return;
    onConnection(LiveConnection.connecting);
    final channel = SupabaseService.client.channel('f1-race-calendar');
    _channel = channel;
    channel
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'races',
      callback: (_) {
        if (identical(_channel, channel)) onChange();
      },
    )
        .subscribe((status, error) {
      if (!identical(_channel, channel)) return;
      // The SDK retries WebSocket connections and channel joins itself.
      onConnection(status == RealtimeSubscribeStatus.subscribed
          ? LiveConnection.connected
          : LiveConnection.reconnecting);
    });
  }

  @override
  Future<void> stop() async {
    final channel = _channel;
    _channel = null;
    if (channel != null) {
      await SupabaseService.client.removeChannel(channel);
    }
  }
}

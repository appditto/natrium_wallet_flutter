import 'package:event_taxi/event_taxi.dart';

// Bus event for connection status changing
enum ConnectionStatus { CONNECTED, DISCONNECTED }

class ConnStatusEvent implements Event {
  final ConnectionStatus status;

  ConnStatusEvent({this.status});
}
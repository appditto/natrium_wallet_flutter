import 'package:event_taxi/event_taxi.dart';

class DisableLockTimeoutEvent implements Event {
  final bool disable;

  DisableLockTimeoutEvent({this.disable});
}
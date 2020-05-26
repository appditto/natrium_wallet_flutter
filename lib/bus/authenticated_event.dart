import 'package:event_taxi/event_taxi.dart';

enum AUTH_EVENT_TYPE { SEND, CHANGE_MANUAL, CHANGE }

class AuthenticatedEvent implements Event {
  final AUTH_EVENT_TYPE authType;

  AuthenticatedEvent(this.authType);
}
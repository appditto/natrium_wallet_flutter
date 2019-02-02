import 'package:event_taxi/event_taxi.dart';

class FcmUpdateEvent implements Event {
  final String token;

  FcmUpdateEvent({this.token});
}
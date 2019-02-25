import 'package:event_taxi/event_taxi.dart';

class AccountChangedEvent implements Event {
  String account;

  AccountChangedEvent({this.account});
}
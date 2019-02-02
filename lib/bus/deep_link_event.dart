import 'package:event_taxi/event_taxi.dart';

class DeepLinkEvent implements Event {
  final bool insufficientBalance;
  final bool invalidDestination;
  final String sendAmount;
  final String sendDestination;

  DeepLinkEvent({this.insufficientBalance = false, this.invalidDestination = false, this.sendAmount, this.sendDestination});
}
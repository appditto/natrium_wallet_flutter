import 'package:event_taxi/event_taxi.dart';

class TransferProcessEvent implements Event {
  final String account;
  final String hash;
  final String balance;

  TransferProcessEvent({this.account, this.hash, this.balance});
}
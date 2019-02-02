import 'package:event_taxi/event_taxi.dart';

class TransferCompleteEvent implements Event {
  final BigInt amount;

  TransferCompleteEvent({this.amount});
}
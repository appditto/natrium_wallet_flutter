import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/model/state_block.dart';

class RepChangedEvent implements Event {
  final StateBlock previous;

  RepChangedEvent({this.previous});
}
import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';

class TransferPendingEvent implements Event {
  final PendingResponse response;

  TransferPendingEvent({this.response});
}
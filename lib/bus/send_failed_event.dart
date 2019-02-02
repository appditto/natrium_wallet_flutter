import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/error_response.dart';

class SendFailedEvent implements Event {
  final ErrorResponse response;

  SendFailedEvent({this.response});
}
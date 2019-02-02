import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';

class ProcessEvent implements Event {
  final ProcessResponse response;

  ProcessEvent({this.response});
}
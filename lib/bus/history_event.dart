import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response.dart';

class HistoryEvent implements Event {
  final AccountHistoryResponse response;

  HistoryEvent({this.response});
}
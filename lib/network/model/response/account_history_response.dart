import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/account_history_response_item.dart';

part 'account_history_response.g.dart';

/// For running in an isolate, needs to be top-level function
AccountHistoryResponse accountHistoryresponseFromJson(Map<dynamic, dynamic> json) {
  return AccountHistoryResponse.fromJson(json);
} 

@JsonSerializable()
class AccountHistoryResponse {
  @JsonKey(name:'history')
  List<AccountHistoryResponseItem> history;

  @JsonKey(ignore: true)
  String account;

  AccountHistoryResponse({List<AccountHistoryResponseItem> history, String account}):super() {
    this.history = history;
    this.account = account;
  }

  factory AccountHistoryResponse.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseToJson(this);
}
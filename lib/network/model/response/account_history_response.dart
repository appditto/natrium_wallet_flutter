import 'package:json_annotation/json_annotation.dart';

import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';

part 'account_history_response.g.dart';

@JsonSerializable()
class AccountHistoryResponse {
  @JsonKey(name:'history')
  List<AccountHistoryResponseItem> history;

  AccountHistoryResponse({List<AccountHistoryResponseItem> history}):super() {
    this.history = history;
  }

  factory AccountHistoryResponse.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseToJson(this);
}
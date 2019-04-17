import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/account_balance_item.dart';

part 'accounts_balances_response.g.dart';

/// For running in an isolate, needs to be top-level function
AccountsBalancesResponse accountsBalancesResponseFromJson(Map<dynamic, dynamic> json) {
  return AccountsBalancesResponse.fromJson(json);
} 

@JsonSerializable()
class AccountsBalancesResponse {
  @JsonKey(name:'balances')
  Map<String, AccountBalanceItem> balances;

  AccountsBalancesResponse({this.balances});

  factory AccountsBalancesResponse.fromJson(Map<String, dynamic> json) => _$AccountsBalancesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountsBalancesResponseToJson(this);
}
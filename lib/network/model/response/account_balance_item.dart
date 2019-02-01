import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';

part 'account_balance_item.g.dart';

@JsonSerializable()
class AccountBalanceItem {
  @JsonKey(name:"balance")
  String balance;

  @JsonKey(name: "pending")
  String pending;

  @JsonKey(ignore: true)
  String privKey;

  @JsonKey(ignore: true)
  String frontier;

  @JsonKey(ignore: true)
  PendingResponse pendingResponse;

  AccountBalanceItem({this.balance, this.pending, this.privKey, this.frontier, this.pendingResponse});

  factory AccountBalanceItem.fromJson(Map<String, dynamic> json) => _$AccountBalanceItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountBalanceItemToJson(this);
}
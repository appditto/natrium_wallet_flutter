import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/account_history_response_item.dart';

part 'account_info_response.g.dart';

int _toInt(String v) => v == null ? 0 : int.tryParse(v);

@JsonSerializable()
class AccountInfoResponse {
  @JsonKey(name:'frontier')
  String frontier;

  @JsonKey(name:'open_block')
  String openBlock;

  @JsonKey(name:'representative_block')
  String representativeBlock;

  @JsonKey(name:'balance')
  String balance;

  @JsonKey(name:'block_count', fromJson: _toInt)
  int blockCount;

  @JsonKey(ignore: true)
  bool unopened;

  AccountInfoResponse({this.frontier, this.openBlock, this.representativeBlock, this.balance, this.blockCount, this.unopened = false}):super();

  factory AccountInfoResponse.fromJson(Map<String, dynamic> json) => _$AccountInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AccountInfoResponseToJson(this);
}
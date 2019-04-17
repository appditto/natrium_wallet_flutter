import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/block_item.dart';

part 'callback_response.g.dart';

/// For running in an isolate, needs to be top-level function
CallbackResponse callbackResponseFromJson(Map<dynamic, dynamic> json) {
  return CallbackResponse.fromJson(json);
} 

/// Represents a callback from the node that belongs to logged in account
@JsonSerializable()
class CallbackResponse {
  @JsonKey(name:"account")
  String account;

  @JsonKey(name:"hash")
  String hash;

  @JsonKey(name:"block")
  BlockItem block;

  @JsonKey(name:"amount")
  String amount;

  @JsonKey(name:"is_send")
  String isSend;

  CallbackResponse({this.account, this.hash, this.block, this.amount, this.isSend});

  factory CallbackResponse.fromJson(Map<String, dynamic> json) => _$CallbackResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CallbackResponseToJson(this);
}
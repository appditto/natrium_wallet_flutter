import 'package:json_annotation/json_annotation.dart';

import 'package:kalium_wallet_flutter/network/model/response/pending_response_item.dart';

part 'pending_response.g.dart';

@JsonSerializable()
class PendingResponse {
  @JsonKey(name:"blocks")
  Map<String, PendingResponseItem> blocks;

  PendingResponse({this.blocks});

  factory PendingResponse.fromJson(Map<String, dynamic> json) => _$PendingResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PendingResponseToJson(this);
}
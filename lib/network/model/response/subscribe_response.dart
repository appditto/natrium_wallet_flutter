import 'package:json_annotation/json_annotation.dart';

part 'subscribe_response.g.dart';

@JsonSerializable()
class SubscribeResponse {
  @JsonKey(name:'frontier')
  String frontier;

  @JsonKey(name:'open_block')
  String openBlock;

  @JsonKey(name:'representative_block')
  String representativeBlock;

  @JsonKey(name:'representative')
  String representative;

  // Balance in RAW
  @JsonKey(name:'balance')
  String balance;

  @JsonKey(name:'block_count')
  int blockCount;

  @JsonKey(name:'pending')
  String pending;

  // Server provides a uuid for each connection
  @JsonKey(name:'uuid')
  String uuid;

  @JsonKey(name:'price')
  String price;

  @JsonKey(name:'btc')
  String btcPrice;

  @JsonKey(name:'nano')
  String nanoPrice;

  SubscribeResponse() {}

  factory SubscribeResponse.fromJson(Map<String, dynamic> json) => _$SubscribeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeResponseToJson(this);
}
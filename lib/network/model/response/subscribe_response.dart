import 'package:json_annotation/json_annotation.dart';

part 'subscribe_response.g.dart';

int _toInt(String v) => v == null ? 0 : int.tryParse(v);

double _toDouble(v) {
  return double.tryParse(v.toString());
}

/// For running in an isolate, needs to be top-level function
SubscribeResponse subscribeResponseFromJson(Map<dynamic, dynamic> json) {
  return SubscribeResponse.fromJson(json);
} 

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

  @JsonKey(name:'block_count', fromJson: _toInt)
  int blockCount;

  @JsonKey(name:'pending')
  String pending;

  // Server provides a uuid for each connection
  @JsonKey(name:'uuid')
  String uuid;

  @JsonKey(name:'price', fromJson:_toDouble)
  double price;

  @JsonKey(name:'btc', fromJson:_toDouble)
  double btcPrice;

  @JsonKey(name:'pending_count')
  int pendingCount;

  @JsonKey(name: 'confirmation_height', nullable: false, fromJson: _toInt)
  int confirmationHeight;

  SubscribeResponse();

  factory SubscribeResponse.fromJson(Map<String, dynamic> json) => _$SubscribeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeResponseToJson(this);
}
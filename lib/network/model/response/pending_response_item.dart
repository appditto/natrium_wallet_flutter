import 'package:json_annotation/json_annotation.dart';

part 'pending_response_item.g.dart';

@JsonSerializable()
class PendingResponseItem {
  @JsonKey(name:"source")
  String source;

  // raw-value of the transaction
  @JsonKey(name:"amount")
  String amount;

  @JsonKey(name:"hash")
  String hash;

  PendingResponseItem({this.source, this.amount, this.hash});

  factory PendingResponseItem.fromJson(Map<String, dynamic> json) => _$PendingResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$PendingResponseItemToJson(this);
}
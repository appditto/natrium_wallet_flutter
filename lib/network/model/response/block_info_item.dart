import 'package:json_annotation/json_annotation.dart';

part 'block_info_item.g.dart';

/// For running in an isolate, needs to be top-level function
BlockInfoItem blockInfoItemFromJson(Map<dynamic, dynamic> json) {
  return BlockInfoItem.fromJson(json);
} 

@JsonSerializable()
class BlockInfoItem {
  @JsonKey(name:'block_account')
  String blockAccount;

  @JsonKey(name:'amount')
  String amount;

  @JsonKey(name:'balance')
  String balance;

  @JsonKey(name:'pending')
  String pending;

  @JsonKey(name:'source_account')
  String sourceAccount;

  @JsonKey(name:'contents')
  String contents;

  BlockInfoItem({String blockAccount, String amount, String balance,
                 String pending, String sourceAccount, String contents}) {
    this.blockAccount = blockAccount;
    this.amount = amount;
    this.balance = balance;
    this.pending = pending;
    this.sourceAccount = sourceAccount;
    this.contents = contents;
  }

  factory BlockInfoItem.fromJson(Map<String, dynamic> json) => _$BlockInfoItemFromJson(json);
  Map<String, dynamic> toJson() => _$BlockInfoItemToJson(this);
}
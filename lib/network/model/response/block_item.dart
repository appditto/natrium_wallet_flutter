import 'package:json_annotation/json_annotation.dart';

part 'block_item.g.dart';

/// Represents a state block
@JsonSerializable()
class BlockItem {
  @JsonKey(name:"type")
  String type;

  @JsonKey(name:"account")
  String account;

  @JsonKey(name:"previous")
  String previous;

  @JsonKey(name:"representative")
  String representative;

  @JsonKey(name:"balance")
  String balance;

  @JsonKey(name:"link")
  String link;

  @JsonKey(name:"link_as_account")
  String linkAsAccount;

  @JsonKey(name:"work")
  String work;

  @JsonKey(name:"signature")
  String signature;

  @JsonKey(name:"destination")
  String destination;

  @JsonKey(name:"source")
  String source;

  BlockItem({this.type, this.account, this.previous, this.representative,
            this.balance, this.link, this.linkAsAccount, this.work,
            this.signature, this.destination, this.source});  

  // Put the generated method here because the compiler doesn't like calling this from its own generate file
  factory BlockItem.fromJson(Map<String, dynamic> json){
      return BlockItem(
      type: json['type'] as String,
      account: json['account'] as String,
      previous: json['previous'] as String,
      representative: json['representative'] as String,
      balance: json['balance'] as String,
      link: json['link'] as String,
      linkAsAccount: json['link_as_account'] as String,
      work: json['work'] as String,
      signature: json['signature'] as String,
      destination: json['destination'] as String,
      source: json['source'] as String);
  }

  Map<String, dynamic> toJson() => _$BlockItemToJson(this);
}
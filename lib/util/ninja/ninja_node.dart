import 'package:json_annotation/json_annotation.dart';
import 'package:decimal/decimal.dart';

part 'ninja_node.g.dart';

double _toDouble(v) {
  return double.tryParse(v.toString());
}

BigInt _toBigInt(v) {
  return BigInt.from(v);
}

/// Represent a node that is returned from the MyNanoNinja API
@JsonSerializable()
class NinjaNode {
  @JsonKey(name:'votingweight', fromJson: _toBigInt)
  BigInt votingWeight;

  @JsonKey(name:'uptime', fromJson: _toDouble)
  double uptime;
  
  @JsonKey(name:'score')
  int score;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'alias')
  String alias;

  NinjaNode({this.votingWeight, this.uptime, this.score, this.account, this.alias});

  factory NinjaNode.fromJson(Map<String, dynamic> json) => _$NinjaNodeFromJson(json);
  Map<String, dynamic> toJson() => _$NinjaNodeToJson(this);
}
import 'package:json_annotation/json_annotation.dart';

part 'ninja_node.g.dart';

/// Represent a node that is returned from the MyNanoNinja API
@JsonSerializable()
class NinjaNode {
  @JsonKey(name:'votingweight')
  BigInt votingWeight;

  @JsonKey(name:'uptime')
  double uptime;
  
  @JsonKey(name:'score')
  int score;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'alias')
  String alias;

  NinjaNode({this.votingWeight, this.uptime, this.score, this.account, thisalias});

  factory NinjaNode.fromJson(Map<String, dynamic> json) => _$NinjaNodeFromJson(json);
  Map<String, dynamic> toJson() => _$NinjaNodeToJson(this);
}
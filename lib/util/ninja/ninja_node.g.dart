// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ninja_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NinjaNode _$NinjaNodeFromJson(Map<String, dynamic> json) {
  return NinjaNode(
      votingWeight: json['votingweight'] == null
          ? null
          : BigInt.parse(json['votingweight'] as String),
      uptime: (json['uptime'] as num)?.toDouble(),
      score: json['score'] as int,
      account: json['account'] as String)
    ..alias = json['alias'] as String;
}

Map<String, dynamic> _$NinjaNodeToJson(NinjaNode instance) => <String, dynamic>{
      'votingweight': instance.votingWeight?.toString(),
      'uptime': instance.uptime,
      'score': instance.score,
      'account': instance.account,
      'alias': instance.alias
    };

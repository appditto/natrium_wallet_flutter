// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateBlock _$StateBlockFromJson(Map<String, dynamic> json) {
  return StateBlock(
    previous: json['previous'] as String,
    representative: json['representative'] as String,
    balance: json['balance'] as String,
    link: json['link'] as String,
    account: json['account'] as String,
  )
    ..type = json['type'] as String
    ..signature = json['signature'] as String;
}

Map<String, dynamic> _$StateBlockToJson(StateBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'previous': instance.previous,
      'account': instance.account,
      'representative': instance.representative,
      'balance': instance.balance,
      'link': instance.link,
      'signature': instance.signature,
    };

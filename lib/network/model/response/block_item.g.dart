// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockItem _$BlockItemFromJson(Map<String, dynamic> json) {
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
    source: json['source'] as String,
  );
}

Map<String, dynamic> _$BlockItemToJson(BlockItem instance) => <String, dynamic>{
      'type': instance.type,
      'account': instance.account,
      'previous': instance.previous,
      'representative': instance.representative,
      'balance': instance.balance,
      'link': instance.link,
      'link_as_account': instance.linkAsAccount,
      'work': instance.work,
      'signature': instance.signature,
      'destination': instance.destination,
      'source': instance.source,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeResponse _$SubscribeResponseFromJson(Map<String, dynamic> json) {
  return SubscribeResponse()
    ..frontier = json['frontier'] as String
    ..openBlock = json['open_block'] as String
    ..representativeBlock = json['representative_block'] as String
    ..representative = json['representative'] as String
    ..balance = json['balance'] as String
    ..blockCount = json['block_count'] == null
        ? null
        : _toInt(json['block_count'] as String)
    ..pending = json['pending'] as String
    ..uuid = json['uuid'] as String
    ..price = json['price'] == null ? null : _toDouble(json['price'])
    ..btcPrice = json['btc'] == null ? null : _toDouble(json['btc'])
    ..pendingCount = json['pending_count'] == null
        ? null
        : _toInt(json['pending_count'] as String);
}

Map<String, dynamic> _$SubscribeResponseToJson(SubscribeResponse instance) =>
    <String, dynamic>{
      'frontier': instance.frontier,
      'open_block': instance.openBlock,
      'representative_block': instance.representativeBlock,
      'representative': instance.representative,
      'balance': instance.balance,
      'block_count': instance.blockCount,
      'pending': instance.pending,
      'uuid': instance.uuid,
      'price': instance.price,
      'btc': instance.btcPrice,
      'pending_count': instance.pendingCount
    };

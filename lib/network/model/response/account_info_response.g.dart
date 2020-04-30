// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInfoResponse _$AccountInfoResponseFromJson(Map<String, dynamic> json) {
  return AccountInfoResponse(
    frontier: json['frontier'] as String,
    openBlock: json['open_block'] as String,
    representativeBlock: json['representative_block'] as String,
    balance: json['balance'] as String,
    blockCount: _toInt(json['block_count'] as String),
  );
}

Map<String, dynamic> _$AccountInfoResponseToJson(
        AccountInfoResponse instance) =>
    <String, dynamic>{
      'frontier': instance.frontier,
      'open_block': instance.openBlock,
      'representative_block': instance.representativeBlock,
      'balance': instance.balance,
      'block_count': instance.blockCount,
    };

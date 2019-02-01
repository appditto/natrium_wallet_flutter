// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocks_info_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlocksInfoRequest _$BlocksInfoRequestFromJson(Map<String, dynamic> json) {
  return BlocksInfoRequest(
      hashes: (json['hashes'] as List)?.map((e) => e as String)?.toList(),
      balance: json['balance'] as bool)
    ..action = json['action'] as String;
}

Map<String, dynamic> _$BlocksInfoRequestToJson(BlocksInfoRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'hashes': instance.hashes,
      'balance': instance.balance
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_info_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockInfoRequest _$BlockInfoRequestFromJson(Map<String, dynamic> json) {
  return BlockInfoRequest(
    hash: json['hash'] as String,
  )..action = json['action'] as String;
}

Map<String, dynamic> _$BlockInfoRequestToJson(BlockInfoRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'hash': instance.hash,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocks_info_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlocksInfoResponse _$BlocksInfoResponseFromJson(Map<String, dynamic> json) {
  return BlocksInfoResponse(
      blocks: (json['blocks'] as Map<String, dynamic>)?.map((k, e) => MapEntry(
          k,
          e == null
              ? null
              : BlockInfoItem.fromJson(e as Map<String, dynamic>))));
}

Map<String, dynamic> _$BlocksInfoResponseToJson(BlocksInfoResponse instance) =>
    <String, dynamic>{'blocks': instance.blocks};

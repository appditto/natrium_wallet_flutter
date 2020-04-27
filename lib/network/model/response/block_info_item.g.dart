// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_info_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockInfoItem _$BlockInfoItemFromJson(Map<String, dynamic> json) {
  return BlockInfoItem(
    blockAccount: json['block_account'] as String,
    amount: json['amount'] as String,
    balance: json['balance'] as String,
    pending: json['pending'] as String,
    sourceAccount: json['source_account'] as String,
    contents: json['contents'] as String,
  );
}

Map<String, dynamic> _$BlockInfoItemToJson(BlockInfoItem instance) =>
    <String, dynamic>{
      'block_account': instance.blockAccount,
      'amount': instance.amount,
      'balance': instance.balance,
      'pending': instance.pending,
      'source_account': instance.sourceAccount,
      'contents': instance.contents,
    };

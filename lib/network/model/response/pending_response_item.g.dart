// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingResponseItem _$PendingResponseItemFromJson(Map<String, dynamic> json) {
  return PendingResponseItem(
    source: json['source'] as String,
    amount: json['amount'] as String,
    hash: json['hash'] as String,
  );
}

Map<String, dynamic> _$PendingResponseItemToJson(
        PendingResponseItem instance) =>
    <String, dynamic>{
      'source': instance.source,
      'amount': instance.amount,
      'hash': instance.hash,
    };

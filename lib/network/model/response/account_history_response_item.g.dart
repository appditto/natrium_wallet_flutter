// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryResponseItem _$AccountHistoryResponseItemFromJson(
    Map<String, dynamic> json) {
  return AccountHistoryResponseItem(
    type: json['type'] as String,
    account: json['account'] as String,
    amount: json['amount'] as String,
    hash: json['hash'] as String,
    height: _toInt(json['height'] as String),
  );
}

Map<String, dynamic> _$AccountHistoryResponseItemToJson(
        AccountHistoryResponseItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'account': instance.account,
      'amount': instance.amount,
      'hash': instance.hash,
      'height': instance.height,
    };

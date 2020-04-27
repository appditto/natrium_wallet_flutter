// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryResponse _$AccountHistoryResponseFromJson(
    Map<String, dynamic> json) {
  return AccountHistoryResponse(
    history: (json['history'] as List)
        ?.map((e) => e == null
            ? null
            : AccountHistoryResponseItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AccountHistoryResponseToJson(
        AccountHistoryResponse instance) =>
    <String, dynamic>{
      'history': instance.history,
    };

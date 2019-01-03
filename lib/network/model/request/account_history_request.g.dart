// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_history_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountHistoryRequest _$AccountHistoryRequestFromJson(
    Map<String, dynamic> json) {
  return AccountHistoryRequest(
      action: json['action'] as String,
      account: json['account'] as String,
      count: json['count'] as int);
}

Map<String, dynamic> _$AccountHistoryRequestToJson(
        AccountHistoryRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
      'count': instance.count
    };

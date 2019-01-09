// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingRequest _$PendingRequestFromJson(Map<String, dynamic> json) {
  return PendingRequest(
      action: json['action'] as String,
      account: json['account'] as String,
      source: json['source'] as bool,
      count: json['count'] as int);
}

Map<String, dynamic> _$PendingRequestToJson(PendingRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
      'source': instance.source,
      'count': instance.count
    };

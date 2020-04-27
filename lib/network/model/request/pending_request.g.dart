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
    count: json['count'] as int,
    threshold: json['threshold'] as String,
    includeActive: json['include_active'] as bool,
  );
}

Map<String, dynamic> _$PendingRequestToJson(PendingRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
    'account': instance.account,
    'source': instance.source,
    'count': instance.count,
    'include_active': instance.includeActive,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('threshold', instance.threshold);
  return val;
}

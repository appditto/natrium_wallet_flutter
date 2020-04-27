// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FcmUpdateRequest _$FcmUpdateRequestFromJson(Map<String, dynamic> json) {
  return FcmUpdateRequest(
    account: json['account'] as String,
    fcmToken: json['fcm_token_v2'] as String,
    enabled: json['enabled'] as bool,
  )..action = json['action'] as String;
}

Map<String, dynamic> _$FcmUpdateRequestToJson(FcmUpdateRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('account', instance.account);
  writeNotNull('fcm_token_v2', instance.fcmToken);
  val['enabled'] = instance.enabled;
  return val;
}

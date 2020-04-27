// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeRequest _$SubscribeRequestFromJson(Map<String, dynamic> json) {
  return SubscribeRequest(
    action: json['action'] as String,
    account: json['account'] as String,
    currency: json['currency'] as String,
    uuid: json['uuid'] as String,
    fcmToken: json['fcm_token_v2'] as String,
    notificationEnabled: json['notification_enabled'] as bool,
  );
}

Map<String, dynamic> _$SubscribeRequestToJson(SubscribeRequest instance) {
  final val = <String, dynamic>{
    'action': instance.action,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('account', instance.account);
  writeNotNull('currency', instance.currency);
  writeNotNull('uuid', instance.uuid);
  writeNotNull('fcm_token_v2', instance.fcmToken);
  val['notification_enabled'] = instance.notificationEnabled;
  return val;
}

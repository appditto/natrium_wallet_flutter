// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscribeRequest _$SubscribeRequestFromJson(Map<String, dynamic> json) {
  return SubscribeRequest(
      account: json['account'] as String,
      currency: json['currency'] as String,
      uuid: json['uuid'] as String,
      fcmToken: json['fcm_token'] as String)
    ..action = json['action'] as String;
}

Map<String, dynamic> _$SubscribeRequestToJson(SubscribeRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
      'currency': instance.currency,
      'uuid': instance.uuid,
      'fcm_token': instance.fcmToken
    };

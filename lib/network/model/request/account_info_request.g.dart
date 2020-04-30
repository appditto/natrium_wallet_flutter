// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_info_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountInfoRequest _$AccountInfoRequestFromJson(Map<String, dynamic> json) {
  return AccountInfoRequest(
    action: json['action'] as String,
    account: json['account'] as String,
  );
}

Map<String, dynamic> _$AccountInfoRequestToJson(AccountInfoRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'account': instance.account,
    };

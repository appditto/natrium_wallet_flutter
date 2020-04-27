// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'callback_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallbackResponse _$CallbackResponseFromJson(Map<String, dynamic> json) {
  return CallbackResponse(
    account: json['account'] as String,
    hash: json['hash'] as String,
    block: json['block'] == null
        ? null
        : BlockItem.fromJson(json['block'] as Map<String, dynamic>),
    amount: json['amount'] as String,
    isSend: json['is_send'] as String,
  );
}

Map<String, dynamic> _$CallbackResponseToJson(CallbackResponse instance) =>
    <String, dynamic>{
      'account': instance.account,
      'hash': instance.hash,
      'block': instance.block,
      'amount': instance.amount,
      'is_send': instance.isSend,
    };

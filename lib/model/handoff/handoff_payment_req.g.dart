// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_payment_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOPaymentRequest _$HOPaymentRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'c', 'd']);
  return HOPaymentRequest(
    json['id'] as String,
    json['c'] as Map<String, dynamic>,
    json['d'] as String,
    _parseBigInt(json['a']),
    json['va'] as bool ?? false,
    json['wk'] as bool ?? false,
  );
}

Map<String, dynamic> _$HOPaymentRequestToJson(HOPaymentRequest instance) =>
    <String, dynamic>{
      'id': instance.paymentId,
      'c': instance.channels,
      'd': instance.destinationAddress,
      'a': _bigIntToString(instance.amount),
      'va': instance.variableAmount,
      'wk': instance.requiresWork,
    };

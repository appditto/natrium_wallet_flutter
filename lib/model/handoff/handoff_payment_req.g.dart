// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_payment_req.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOPaymentRequest _$HandoffPaymentSpecFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'c']);
  return HOPaymentRequest(
    json['id'] as String,
    json['c'] as Map<String, dynamic>,
    json['d'] as String,
    _parseBigInt(json['a']),
    json['v'] as bool ?? false,
    json['w'] as bool ?? false,
  );
}

Map<String, dynamic> _$HandoffPaymentSpecToJson(HOPaymentRequest instance) =>
    <String, dynamic>{
      'id': instance.paymentId,
      'c': instance.channels,
      'd': instance.destinationAddress,
      'a': _bigIntToString(instance.amount),
      'v': instance.variableAmount,
      'w': instance.requiresWork,
    };

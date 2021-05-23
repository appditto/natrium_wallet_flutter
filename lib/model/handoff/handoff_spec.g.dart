// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffPaymentSpec _$HandoffPaymentSpecFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'c']);
  return HandoffPaymentSpec(
    json['id'] as String,
    json['c'] as Map<String, dynamic>,
    json['d'] as String,
    _parseBigInt(json['a']),
    json['va'] as bool ?? false,
    json['wk'] as bool ?? false,
    json['re'] as bool ?? false,
  );
}

Map<String, dynamic> _$HandoffPaymentSpecToJson(HandoffPaymentSpec instance) =>
    <String, dynamic>{
      'id': instance.paymentId,
      'c': instance.channels,
      'd': instance.destinationAddress,
      'a': _bigIntToString(instance.amount),
      'va': instance.variableAmount,
      'wk': instance.requiresWork,
      're': instance.reusable,
    };

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

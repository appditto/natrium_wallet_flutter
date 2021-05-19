// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HandoffResponse _$HandoffResponseFromJson(Map<String, dynamic> json) {
  return HandoffResponse(
    _statusFromCode(json['status'] as int),
    message: json['msg'] as String,
    reference: json['ref'] as String,
  );
}

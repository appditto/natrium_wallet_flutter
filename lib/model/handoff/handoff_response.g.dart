// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HOResponse _$HandoffResponseFromJson(Map<String, dynamic> json) {
  return HOResponse(
    _statusFromCode(json['status'] as int),
    message: json['msg'] as String,
    reference: json['ref'] as String,
    nextId: json['next_id'] as String,
  );
}

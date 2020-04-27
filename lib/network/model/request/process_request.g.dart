// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'process_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProcessRequest _$ProcessRequestFromJson(Map<String, dynamic> json) {
  return ProcessRequest(
    block: json['block'] as String,
    doWork: json['do_work'] as bool,
    subType: json['subtype'] as String,
  )..action = json['action'] as String;
}

Map<String, dynamic> _$ProcessRequestToJson(ProcessRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'block': instance.block,
      'do_work': instance.doWork,
      'subtype': instance.subType,
    };

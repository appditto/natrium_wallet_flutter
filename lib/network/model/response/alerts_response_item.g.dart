// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_response_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertResponseItem _$AlertResponseItemFromJson(Map<String, dynamic> json) {
  return AlertResponseItem(
    id: json['id'] as int,
    active: json['active'] as bool,
    priority: json['priority'] as String,
    title: json['title'] as String,
    shortDescription: json['short_description'] as String,
    longDescription: json['long_description'] as String,
    link: json['link'] as String,
    timestamp: json['timestamp'] as int,
  );
}

Map<String, dynamic> _$AlertResponseItemToJson(AlertResponseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'priority': instance.priority,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'long_description': instance.longDescription,
      'link': instance.link,
      'timestamp': instance.timestamp,
    };

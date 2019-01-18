import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

part 'contact.g.dart';

@JsonSerializable()
class Contact {
  @JsonKey(ignore:true)
  int id;
  @JsonKey(name:'name')
  String name;
  @JsonKey(name:'address')
  String address;
  @JsonKey(ignore:true)
  String monkeyPath;
  @JsonKey(ignore:true)
  Widget monkeyWidget;
  @JsonKey(ignore:true)
  Widget monkeyWidgetLarge;

  Contact({@required this.name, @required this.address, this.monkeyPath, int id});

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);
  Map<String, dynamic> toJson() => _$ContactToJson(this);

  bool operator ==(o) => o is Contact && o.name == name && o.address == address;
  int get hashCode => hash2(name.hashCode, address.hashCode);
}
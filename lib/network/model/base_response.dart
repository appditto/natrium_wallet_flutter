import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class BaseResponse {
  @JsonKey(name:'messageType')
  String messageType;

  BaseResponse({String messageType}) {
    this.messageType = messageType;
  }
}
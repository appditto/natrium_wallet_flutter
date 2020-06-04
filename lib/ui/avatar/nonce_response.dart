import 'package:json_annotation/json_annotation.dart';

part 'nonce_response.g.dart';

@JsonSerializable()
class NonceResponse {
  @JsonKey(name:'nonce')
  int nonce;

  NonceResponse({this.nonce}) : super();

  factory NonceResponse.fromJson(Map<String, dynamic> json) => _$NonceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NonceResponseToJson(this);
}
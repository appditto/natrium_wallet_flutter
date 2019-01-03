import 'package:json_annotation/json_annotation.dart';

class BaseRequest {
  // After this time a request will expire
  static const int EXPIRE_TIME_S = 15;

  @JsonKey(ignore: true)
  DateTime expireDt;
  @JsonKey(ignore: true)
  bool isProcessing;

  BaseRequest() {
    expireDt = DateTime.now().add(new Duration(seconds: EXPIRE_TIME_S));
    isProcessing = false;
  }
}
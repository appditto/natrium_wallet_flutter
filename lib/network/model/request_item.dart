import 'dart:convert';

/// Top-level function for running in isolate via flutter compute function
String encodeRequestItem(dynamic request) {
  return json.encode(request.toJson());
}

class RequestItem<T> {
  // After this time a request will expire
  static const int EXPIRE_TIME_S = 15;

  DateTime _expireDt;
  bool _isProcessing;
  T _request;
  bool fromTransfer;

  RequestItem(T request, {bool fromTransfer = false}) {
    _expireDt = DateTime.now().add(new Duration(seconds: EXPIRE_TIME_S));
    _isProcessing = false;
    _request = request;
    this.fromTransfer = fromTransfer;
  }

  T get request => _request;

  set request(T value) {
    _request = value;
  }

  bool get isProcessing => _isProcessing;

  set isProcessing(bool value) {
    _isProcessing = value;
  }

  DateTime get expireDt => _expireDt;

  set expireDt(DateTime value) {
    _expireDt = value;
  }
}
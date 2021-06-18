import 'dart:convert';

import 'package:http/http.dart' as http;

import 'handoff_response.dart';

enum HOChannel { https }

extension HOChannelExt on HOChannel {
  /// Returns the protocol name of this type
  String get name {
    switch (this) {
      case HOChannel.https:
        return 'https';
      default: throw AssertionError();
    }
  }

  /// Parses the specified channel object from the given properties object
  HOChannelDispatcher parse(dynamic properties) {
    switch (this) {
      case HOChannel.https:
        return HttpsChannelDispatcher.fromSpec(properties);
      default: throw AssertionError();
    }
  }
}

abstract class HOChannelDispatcher {
  final HOChannel type;
  HOChannelDispatcher(this.type);

  Future<HOResponse> dispatchBlock(String paymentId, Map<String, dynamic> blockContents);
}


/// HTTPS
class HttpsChannelDispatcher extends HOChannelDispatcher {
  final Uri url;
  HttpsChannelDispatcher(this.url) : super(HOChannel.https);

  factory HttpsChannelDispatcher.fromSpec(dynamic properties) {
    return HttpsChannelDispatcher(Uri.parse("https://" + properties['url']));
  }

  @override
  Future<HOResponse> dispatchBlock(String paymentId, Map<String, dynamic> block) async {
    var response = await http.post(url,
        body: _createRequestJson(paymentId, block),
        headers: {'Content-type': 'application/json'})
        .timeout(Duration(seconds: 15));
    return HOResponse.fromJson(json.decode(response.body));
  }
}


/// Creates a request using the generic JSON model
String _createRequestJson(String paymentId, Map<String, dynamic> block) {
  return json.encode({'id': paymentId, 'block': block});
}
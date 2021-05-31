import 'dart:convert';

import 'package:http/http.dart' as http;

import 'handoff_response.dart';

enum HandoffChannel { https }

extension HandoffChannelExt on HandoffChannel {
  /// Returns the protocol name of this type
  String get name {
    switch (this) {
      case HandoffChannel.https:
        return 'https';
      default: throw AssertionError();
    }
  }

  /// Parses the specified channel object from the given properties object
  HandoffChannelProcessor parse(dynamic properties) {
    switch (this) {
      case HandoffChannel.https:
        return HttpsChannelProcessor.fromSpec(properties);
      default: throw AssertionError();
    }
  }
}


abstract class HandoffChannelProcessor {
  final HandoffChannel type;
  HandoffChannelProcessor(this.type);

  Future<HandoffResponse> handoffBlock(String paymentId, Map<String, dynamic> blockContents);
}

/// HTTPS
class HttpsChannelProcessor extends HandoffChannelProcessor {
  final Uri url;
  HttpsChannelProcessor(this.url) : super(HandoffChannel.https);

  factory HttpsChannelProcessor.fromSpec(dynamic properties) {
    return HttpsChannelProcessor(Uri.parse("https://" + properties['url']));
  }

  @override
  Future<HandoffResponse> handoffBlock(String paymentId, Map<String, dynamic> block) async {
    var response = await http.post(url,
        body: _createRequestJson(paymentId, block),
        headers: {'Content-type': 'application/json'})
        .timeout(Duration(seconds: 15));
    return HandoffResponse.fromJson(json.decode(response.body));
  }
}


/// Creates a request using the generic JSON model
String _createRequestJson(String paymentId, Map<String, dynamic> block) {
  return json.encode({'id': paymentId, 'block': block});
}
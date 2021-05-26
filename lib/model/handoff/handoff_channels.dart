import 'dart:convert';

import 'package:http/http.dart' as http;

import 'handoff_response.dart';

enum ChannelType { https }

extension ChannelTypeExt on ChannelType {
  /// Returns the protocol name of this type
  String get name {
    switch (this) {
      case ChannelType.https: return 'https';
    }
    throw AssertionError();
  }

  /// Parses the specified channel object from the given properties object
  HandoffChannel parse(dynamic properties) {
    switch (this) {
      case ChannelType.https:
        return HttpsHandoffChannel.fromProperties(properties);
    }
    throw AssertionError();
  }
}


abstract class HandoffChannel {
  final ChannelType type;
  HandoffChannel(this.type);

  Future<HandoffResponse> handoffBlock(String paymentId, Map<String, dynamic> blockContents);
}

/// HTTPS
class HttpsHandoffChannel extends HandoffChannel {
  final Uri url;
  HttpsHandoffChannel(this.url) : super(ChannelType.https);

  factory HttpsHandoffChannel.fromProperties(dynamic properties) {
    return HttpsHandoffChannel(Uri.parse("https://" + properties['url']));
  }

  @override
  Future<HandoffResponse> handoffBlock(String paymentId, Map<String, dynamic> blockContents) async {
    var response = await http.post(url,
        body: _createRequestJson(paymentId, blockContents),
        headers: {'Content-type': 'application/json'})
        .timeout(Duration(seconds: 15));
    return HandoffResponse.fromJson(json.decode(response.body));
  }
}


/// Creates a request using the generic JSON model
String _createRequestJson(String paymentId, Map<String, dynamic> blockContents) {
  return json.encode({'id': paymentId, 'block': blockContents});
}
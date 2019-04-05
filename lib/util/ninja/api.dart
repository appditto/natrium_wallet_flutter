import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';

class NinjaAPI {
  static const String API_URL = 'https://mynano.ninja/api';

  /// Get verified nodes, return null if an error occured
  static Future<List<NinjaNode>> getVerifiedNodes() async {
    String url = API_URL + '/accounts/verified';
    http.Response response = await http.get(url);
    if (response.statusCode != 200) {
      return null;
    }
    List<NinjaNode> ninjaNodes = (json.decode(response.body) as List).map((e) => new NinjaNode.fromJson(e)).toList();
    return ninjaNodes;
  }
}
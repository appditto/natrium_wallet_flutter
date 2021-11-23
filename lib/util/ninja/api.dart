import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';

class NinjaAPI {
  static const String API_URL = 'https://mynano.ninja/api';

  static Future<String> getAndCacheAPIResponse() async {
    String url = API_URL + '/accounts/verified';
    http.Response response = await http.get(Uri.parse(url), headers: {});
    if (response.statusCode != 200) {
      return null;
    }
    await sl.get<SharedPrefsUtil>().setNinjaAPICache(response.body);
    return response.body;
  }

  /// Get verified nodes, return null if an error occured
  static Future<List<NinjaNode>> getVerifiedNodes() async {
    String httpResponseBody = await getAndCacheAPIResponse();
    if (httpResponseBody == null) {
      return null;
    }
    List<NinjaNode> ninjaNodes = (json.decode(httpResponseBody) as List)
        .map((e) => new NinjaNode.fromJson(e))
        .toList();
    return ninjaNodes;
  }

  static Future<List<NinjaNode>> getCachedVerifiedNodes() async {
    String rawJson = await sl.get<SharedPrefsUtil>().getNinjaAPICache();
    if (rawJson == null) {
      return null;
    }
    List<NinjaNode> ninjaNodes = (json.decode(rawJson) as List)
        .map((e) => new NinjaNode.fromJson(e))
        .toList();
    return ninjaNodes;
  }
}

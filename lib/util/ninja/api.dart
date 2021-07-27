import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';

class NinjaAPI {
  static const String API_URL = 'http://localhost:5076/api';
  //static const String API_URL = 'https://mynano.ninja/api';

  static Future<String> getAndCacheAPIResponse() async {
    String url = API_URL + '/accounts/verified';
    http.Response response = await http.get(url, headers:  {});
    if (response.statusCode != 200) {
      return null;
    }
    await sl.get<SharedPrefsUtil>().setNinjaAPICache(response.body);
    return response.body;
  }

  /// Get verified nodes, return null if an error occured
  static Future<List<NinjaNode>> getVerifiedNodes() async {
    //String httpResponseBody = await getAndCacheAPIResponse();
    String httpResponseBody = "["
                + "    {"
                + "        \"votingweight\": 3.2885873412683238e+35,"
                + "        \"delegators\": 2146,"
                + "        \"uptime\": 96.75324675324676,"
                + "        \"score\": 100,"
                + "        \"account\": \"btco_36u6rwcg9us6wwrgcdt7xyqz4wm4e9y48goahfup6zuqabhfrx5x7g1xdddi\","
                + "        \"alias\": \"BTCO Official Representative 01\""
                + "    },"
                + "    {"
                + "        \"votingweight\": 3.833534711796325e+35,"
                + "        \"delegators\": 2446,"
                + "        \"uptime\": 99.75587371512482,"
                + "        \"score\": 100,"
                + "        \"account\": \"btco_36qaepuktgazzkxtwwdngk3ihisxmchmnfpignhrp7xqe8nxebtcdkunytda\","
                + "        \"alias\": \"BTCO Official Representative 02\""
                + "    },"
                + "    {"
                + "        \"votingweight\": 3.868206181988843e+35,"
                + "        \"delegators\": 1568,"
                + "        \"uptime\": 97.66410787241449,"
                + "        \"score\": 100,"
                + "        \"account\": \"btco_3tu3fqfrcpqcwwrm8g6puzknft5uhxjezztfjracgo9jx4posik5szbn5waz\","
                + "        \"alias\": \"BTCO Official Representative 03\""
                + "    },"
                + "    {"
                + "        \"votingweight\": 3.366143318317386e+35,"
                + "        \"delegators\": 1154,"
                + "        \"uptime\": 99.22885277019813,"
                + "        \"score\": 99,"
                + "        \"account\": \"btco_1pprkm1z961ne88ocysdze9uq3o4ctfjtpinfgsjthuuqxgt37tbhpzfb9zi\","
                + "        \"alias\": \"BTCO Official Representative 04\""
                + "    },"
                + "    {"
                + "        \"votingweight\": 3.749306910603174e+35,"
                + "        \"delegators\": 3217,"
                + "        \"uptime\": 99.16662077574023,"
                + "        \"score\": 99,"
                + "        \"account\": \"btco_3jrokzqbee3kyugs3nbq85jpjood486iu8ub6gsinfbcwq49khchu8h9yfp9\","
                + "        \"alias\": \"BTCO Official Representative 05\""
                + "    }"
                + "]";
    if (httpResponseBody == null) {
      return null;
    }
    List<NinjaNode> ninjaNodes = (json.decode(httpResponseBody) as List).map((e) => new NinjaNode.fromJson(e)).toList();
    return ninjaNodes;
  }

  static Future<List<NinjaNode>> getCachedVerifiedNodes() async {
    String rawJson = await sl.get<SharedPrefsUtil>().getNinjaAPICache();
    if (rawJson == null) {
      return null;
    }
    List<NinjaNode> ninjaNodes = (json.decode(rawJson) as List).map((e) => new NinjaNode.fromJson(e)).toList();
    return ninjaNodes;    
  }
}
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/**
 * Securely store and retrieve the seed(s) on device
 */
class Vault {
  static const String seedKey = 'fkalium_seed';
  final FlutterSecureStorage secureStorage = new FlutterSecureStorage();

  Future<String> getSeed() async {
    String value = await secureStorage.read(key: seedKey);
    return value;
  }

  Future<String> writeSeed(String seed) async {
    await secureStorage.write(key: seedKey, value:seed);
    return seed;
  }

  Future<void> deleteSeed() async {
    return await secureStorage.delete(key: seedKey);
  }
}
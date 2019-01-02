import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/**
 * Singleton for keystore access methods in android/iOS
 */
class Vault {
  Vault._internal();
  static final Vault _singleton = new Vault._internal();
  static Vault get inst => _singleton;

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
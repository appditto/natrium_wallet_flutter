import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/**
 * Singleton for keystore access methods in android/iOS
 */
class Vault {
  Vault._internal();
  static final Vault _singleton = new Vault._internal();
  static Vault get inst => _singleton;

  static const String seedKey = 'fkalium_seed';
  static const String encryptionKey = 'fkalium_secret_phrase';
  static const String pinKey = 'fkalium_pin';
  final FlutterSecureStorage secureStorage = new FlutterSecureStorage();

  // Re-usable
  Future<String> _write(String key, String value) async {
    await secureStorage.write(key:key, value:value);
    return value;
  }

  Future<String> _read(String key, {String defaultValue}) async {
    return await secureStorage.read(key:key) ?? defaultValue;
  }

  Future<void> deleteAll() async {
    return await secureStorage.deleteAll();
  }

  // Specific keys
  Future<String> getSeed() async {
    return await _read(seedKey);
  }

  Future<String> setSeed(String seed) async {
    return await _write(seedKey, seed);
  }

  Future<void> deleteSeed() async {
    return await secureStorage.delete(key: seedKey);
  }

  Future<String> getEncryptionPhrase() async {
    return await _read(encryptionKey);
  }

  Future<String> writeEncryptionPhrase(String secret) async {
    return await _write(encryptionKey, secret);
  }

  Future<void> deleteEncryptionPhrase() async {
    return await secureStorage.delete(key: encryptionKey);
  }

  Future<String> getPin() async {
    return await _read(pinKey);
  }

  Future<String> writePin(String pin) async {
    return await _write(pinKey, pin);
  }

  Future<void> deletePin() async {
    return await secureStorage.delete(key: pinKey);
  }
}
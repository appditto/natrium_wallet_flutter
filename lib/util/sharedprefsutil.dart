import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalium_wallet_flutter/util/encrypt.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/available_currency.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/model/wallet.dart';

/// Price conversion preference values
enum PriceConversion { BTC, NANO, NONE }

/// Singleton wrapper for shared preferences
class SharedPrefsUtil {
  SharedPrefsUtil._internal();
  static final SharedPrefsUtil _singleton = new SharedPrefsUtil._internal();
  static SharedPrefsUtil get inst => _singleton;

  // Keys
  static const String seed_backed_up_key = 'fkalium_seed_backup';
  static const String app_uuid_key = 'fkalium_app_uuid';
  static const String price_conversion = 'fkalium_price_conversion_pref';
  static const String auth_method = 'fkalium_auth_method';
  static const String cur_currency = 'fkalium_currency_pref';
  static const String user_representative = 'fkalium_user_rep'; // For when non-opened accounts have set a representative

  // For plain-text data
  Future<void> set(String key, value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    }
  }

  Future<dynamic> get(String key, {dynamic defaultValue}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.get(key) ?? defaultValue;
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String value) async {
    // Retrieve/Generate encryption password
    String secret = await Vault.inst.getEncryptionPhrase();
    if (secret == null) {
      secret = Salsa20Encryptor.generateEncryptionSecret(16) + ":" + Salsa20Encryptor.generateEncryptionSecret(8);
      await Vault.inst.writeEncryptionPhrase(secret);
    }
    // Encrypt and save
    Salsa20Encryptor encrypter = new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String> getEncrypted(String key) async {
    String secret = await Vault.inst.getEncryptionPhrase();
    if (secret == null) return null;
    // Decrypt and return
    Salsa20Encryptor encrypter = new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encrypted = prefs.get(key);
    if (encrypted == null) return null;
    return encrypter.decrypt(encrypted);
  }

  // Key-specific helpers
  Future<void> setSeedBackedUp(bool value) async {
    return await set(seed_backed_up_key, value);
  }

  Future<bool> getSeedBackedUp() async {
    return await get(seed_backed_up_key, defaultValue: false);
  }

  Future<void> setUuid(String uuid) async {
    return await setEncrypted(app_uuid_key, uuid);
  }

  Future<String> getUuid() async {
    return await getEncrypted(app_uuid_key);
  }


  Future<void> setPriceConversion(PriceConversion conversion) async {
   return await set(price_conversion, conversion.index);
  }

  Future<PriceConversion> getPriceConversion() async {
    return PriceConversion.values[await get(price_conversion, defaultValue: PriceConversion.BTC.index)];
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
   return await set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(AuthMethod.values[await get(auth_method, defaultValue: AuthMethod.BIOMETRICS.index)]);
  }

  Future<void> setCurrency(AvailableCurrency currency) async {
   return await set(cur_currency, currency.getIndex());
  }

  Future<AvailableCurrency> getCurrency() async {
    // TODO - default to the device locale
    return AvailableCurrency(AvailableCurrencyEnum.values[await get(cur_currency, defaultValue: AvailableCurrencyEnum.USD.index)]);
  }

  Future<void> setRepresentative(String rep) async {
    return await set(user_representative, rep);
  }

  Future<String> getRepresentative() async {
    return get(user_representative, defaultValue: KaliumWallet.defaultRepresentative);
  }

  // For logging out
  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(seed_backed_up_key);
    prefs.remove(app_uuid_key);
    prefs.remove(price_conversion);
  }
}
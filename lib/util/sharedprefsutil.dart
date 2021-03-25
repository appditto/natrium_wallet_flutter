import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:natrium_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:natrium_wallet_flutter/util/random_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/util/encrypt.dart';
import 'package:natrium_wallet_flutter/model/available_themes.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/available_currency.dart';
import 'package:natrium_wallet_flutter/model/available_language.dart';
import 'package:natrium_wallet_flutter/model/available_block_explorer.dart';
import 'package:natrium_wallet_flutter/model/device_lock_timeout.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/model/wallet.dart';

/// Price conversion preference values
enum PriceConversion { BTC, NONE, HIDDEN }

/// Singleton wrapper for shared preferences
class SharedPrefsUtil {
  // Keys
  static const String first_launch_key = 'fkalium_first_launch';
  static const String seed_backed_up_key = 'fkalium_seed_backup';
  static const String app_uuid_key = 'fkalium_app_uuid';
  static const String price_conversion = 'fkalium_price_conversion_pref';
  static const String auth_method = 'fkalium_auth_method';
  static const String cur_currency = 'fkalium_currency_pref';
  static const String cur_language = 'fkalium_language_pref';
  static const String cur_theme = 'fkalium_theme_pref';
  static const String cur_explorer = 'fkalium_cur_explorer_pref';
  static const String user_representative =
      'fkalium_user_rep'; // For when non-opened accounts have set a representative
  static const String firstcontact_added = 'fkalium_first_c_added';
  static const String notification_enabled = 'fkalium_notification_on';
  static const String lock_kalium = 'fkalium_lock_dev';
  static const String kalium_lock_timeout = 'fkalium_lock_timeout';
  static const String has_shown_root_warning =
      'fkalium_root_warn'; // If user has seen the root/jailbreak warning yet
  // For maximum pin attempts
  static const String pin_attempts = 'fkalium_pin_attempts';
  static const String pin_lock_until = 'fkalium_lock_duraton';
  // For certain keystore incompatible androids
  static const String use_legacy_storage = 'fkalium_legacy_storage';
  // Caching ninja API response
  static const String ninja_api_cache = 'fkalium_ninja_api_cache';
  // Natricon setting
  static const String use_natricon = 'natrium_use_natricon';

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

  /// Set a key with an expiry, expiry is in seconds
  Future<void> setWithExpiry(String key, dynamic value, int expiry) async {
    int expiryVal;
    if (expiry != -1) {
      DateTime now = DateTime.now().toUtc();
      DateTime expired = now.add(Duration(seconds: expiry));
      expiryVal = expired.millisecondsSinceEpoch;
    } else {
      expiryVal = expiry;
    }
    Map<String, dynamic> msg = {
      'data':value,
      'expiry':expiryVal
    };
    String serialized = json.encode(msg);
    await set(key, serialized);
  }

  /// Get a key that has an expiry
  Future<dynamic> getWithExpiry(String key) async {
    String val = await get(key, defaultValue: null);
    if (val == null) {
      return null;
    }
    Map<String, dynamic> msg = json.decode(val);
    if (msg['expiry'] != -1) {
      DateTime expired = DateTime.fromMillisecondsSinceEpoch(msg['expiry']);
      if (DateTime.now().toUtc().difference(expired).inMinutes > 0) {
        await remove(key);
        return null;
      }
    }
    return msg['data'];
  }

  Future<void> remove(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(key);
  }

  // For encrypted data
  Future<void> setEncrypted(String key, String value) async {
    // Retrieve/Generate encryption password
    String secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) {
      secret = RandomUtil.generateEncryptionSecret(16) +
          ":" +
          RandomUtil.generateEncryptionSecret(8);
      await sl.get<Vault>().writeEncryptionPhrase(secret);
    }
    // Encrypt and save
    Salsa20Encryptor encrypter =
        new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String> getEncrypted(String key) async {
    String secret = await sl.get<Vault>().getEncryptionPhrase();
    if (secret == null) return null;
    // Decrypt and return
    Salsa20Encryptor encrypter =
        new Salsa20Encryptor(secret.split(":")[0], secret.split(":")[1]);
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

  Future<void> setHasSeenRootWarning() async {
    return await set(has_shown_root_warning, true);
  }

  Future<bool> getHasSeenRootWarning() async {
    return await get(has_shown_root_warning, defaultValue: false);
  }

  Future<void> setFirstLaunch() async {
    return await set(first_launch_key, false);
  }

  Future<bool> getFirstLaunch() async {
    return await get(first_launch_key, defaultValue: true);
  }

  Future<void> setFirstContactAdded(bool value) async {
    return await set(firstcontact_added, value);
  }

  Future<bool> getFirstContactAdded() async {
    return await get(firstcontact_added, defaultValue: false);
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
    return PriceConversion.values[
        await get(price_conversion, defaultValue: PriceConversion.BTC.index)];
  }

  Future<void> setAuthMethod(AuthenticationMethod method) async {
    return await set(auth_method, method.getIndex());
  }

  Future<AuthenticationMethod> getAuthMethod() async {
    return AuthenticationMethod(AuthMethod.values[
        await get(auth_method, defaultValue: AuthMethod.BIOMETRICS.index)]);
  }

  Future<void> setCurrency(AvailableCurrency currency) async {
    return await set(cur_currency, currency.getIndex());
  }

  Future<AvailableCurrency> getCurrency(Locale deviceLocale) async {
    return AvailableCurrency(AvailableCurrencyEnum.values[await get(
        cur_currency,
        defaultValue:
            AvailableCurrency.getBestForLocale(deviceLocale).currency.index)]);
  }

  Future<void> setLanguage(LanguageSetting language) async {
    return await set(cur_language, language.getIndex());
  }

  Future<LanguageSetting> getLanguage() async {
    return LanguageSetting(AvailableLanguage.values[await get(cur_language,
        defaultValue: AvailableLanguage.DEFAULT.index)]);
  }

  Future<void> setTheme(ThemeSetting theme) async {
    return await set(cur_theme, theme.getIndex());
  }

  Future<void> setBlockExplorer(AvailableBlockExplorer explorer) async {
    return await set(cur_explorer, explorer.getIndex());
  }

  Future<AvailableBlockExplorer> getBlockExplorer() async {
    return AvailableBlockExplorer(AvailableBlockExplorerEnum.values[await get(cur_explorer,
        defaultValue: AvailableBlockExplorerEnum.NANOCRAWLER.index)]);
  }

  Future<ThemeSetting> getTheme() async {
    return ThemeSetting(ThemeOptions.values[
        await get(cur_theme, defaultValue: ThemeOptions.NATRIUM.index)]);
  }

  Future<void> setRepresentative(String rep) async {
    return await set(user_representative, rep);
  }

  Future<String> getRepresentative() async {
    return await get(user_representative,
        defaultValue: AppWallet.defaultRepresentative);
  }

  Future<void> setNotificationsOn(bool value) async {
    return await set(notification_enabled, value);
  }

  Future<bool> getNotificationsOn() async {
    // Notifications off by default on iOS,
    bool defaultValue = Platform.isIOS ? false : true;
    return await get(notification_enabled, defaultValue: defaultValue);
  }

  /// If notifications have been set by user/app
  Future<bool> getNotificationsSet() async {
    return await get(notification_enabled, defaultValue: null) == null
        ? false
        : true;
  }

  Future<void> setLock(bool value) async {
    return await set(lock_kalium, value);
  }

  Future<bool> getLock() async {
    return await get(lock_kalium, defaultValue: false);
  }

  Future<void> setLockTimeout(LockTimeoutSetting setting) async {
    return await set(kalium_lock_timeout, setting.getIndex());
  }

  Future<LockTimeoutSetting> getLockTimeout() async {
    return LockTimeoutSetting(LockTimeoutOption.values[await get(
        kalium_lock_timeout,
        defaultValue: LockTimeoutOption.ONE.index)]);
  }

  // Locking out when max pin attempts exceeded
  Future<int> getLockAttempts() async {
    return await get(pin_attempts, defaultValue: 0);
  }

  Future<void> incrementLockAttempts() async {
    await set(pin_attempts, await getLockAttempts() + 1);
  }

  Future<void> resetLockAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
  }

  Future<bool> shouldLock() async {
    if (await get(pin_lock_until) != null || await getLockAttempts() >= 5) {
      return true;
    }
    return false;
  }

  Future<void> updateLockDate() async {
    int attempts = await getLockAttempts();
    if (attempts >= 20) {
      // 4+ failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(hours: 24))));
    } else if (attempts >= 15) {
      // 3 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 15))));
    } else if (attempts >= 10) {
      // 2 failed attempts
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 5))));
    } else if (attempts >= 5) {
      await set(
          pin_lock_until,
          DateFormat.yMd()
              .add_jms()
              .format(DateTime.now().toUtc().add(Duration(minutes: 1))));
    }
  }

  Future<DateTime> getLockDate() async {
    String lockDateStr = await get(pin_lock_until);
    if (lockDateStr == null) {
      return null;
    }
    return DateFormat.yMd().add_jms().parseUtc(lockDateStr);
  }

  Future<bool> useLegacyStorage() async {
    return await get(use_legacy_storage, defaultValue: false);
  }

  Future<void> setUseLegacyStorage() async {
    await set(use_legacy_storage, true);
  }

  Future<String> getNinjaAPICache() async {
    return await get(ninja_api_cache, defaultValue: null);
  }

  Future<void> setNinjaAPICache(String data) async {
    await set(ninja_api_cache, data);
  }

  Future<void> setUseNatricon(bool useNatricon) async {
    return await set(use_natricon, useNatricon);
  }

  Future<bool> getUseNatricon() async {
    return await get(use_natricon, defaultValue: true);
  }

  Future<void> dismissAlert(AlertResponseItem alert) async {
    await setWithExpiry("alert_${alert.id}", alert.id, -1);
  }

  Future<void> markAlertRead(AlertResponseItem alert) async {
    await setWithExpiry("alertread_${alert.id}", alert.id, -1);
  }

  Future<bool> alertIsRead(AlertResponseItem alert) async {
    int exists = await getWithExpiry("alertread_${alert.id}");
    return exists == null ? false : true;
  }

  Future<bool> shouldShowAlert(AlertResponseItem alert) async {
    int exists = await getWithExpiry("alert_${alert.id}");
    return exists == null ? true: false;
  }

  // For logging out
  Future<void> deleteAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(seed_backed_up_key);
    await prefs.remove(app_uuid_key);
    await prefs.remove(price_conversion);
    await prefs.remove(user_representative);
    await prefs.remove(cur_currency);
    await prefs.remove(auth_method);
    await prefs.remove(notification_enabled);
    await prefs.remove(lock_kalium);
    await prefs.remove(pin_attempts);
    await prefs.remove(pin_lock_until);
    await prefs.remove(kalium_lock_timeout);
    await prefs.remove(has_shown_root_warning);
    await prefs.remove(use_natricon);
  }
}

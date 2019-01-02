import 'package:shared_preferences/shared_preferences.dart';

/**
 * Singleton wrapper for shared preferences
 */
class SharedPrefsUtil {
  SharedPrefsUtil._internal();
  static final SharedPrefsUtil _singleton = new SharedPrefsUtil._internal();
  static SharedPrefsUtil get inst => _singleton;

  // Keys
  static const String seed_backed_up_key = 'fkalium_seed_backup';

  Future<void> setSeedBackedUp(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(seed_backed_up_key, value);
  }

  Future<bool> getSeedBackedUp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(seed_backed_up_key) ?? false;
  }
}
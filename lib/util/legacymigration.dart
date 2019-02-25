
import 'dart:io';
import 'package:flutter/services.dart';

// Tools to help us migrate from the old android app to the new Flutter app
class LegacyMigration {
  static const _channel = const MethodChannel('fappchannel');

  static Future<String> getLegacySeed() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return await _channel.invokeMethod('getLegacySeed');
  }

  static Future<String> getLegacyContacts() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return await _channel.invokeMethod('getLegacyContacts');
  }

  static Future<void> deleteLegacyData() async {
    if (!Platform.isAndroid) {
      return null;
    }
    return await _channel.invokeMethod('clearLegacyData');
  }
}
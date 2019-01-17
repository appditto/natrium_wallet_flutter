import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

class ClipboardUtil {
  static bool eventSet = false;

  /// Set to clear clipboard after 2 minutes, if clipboard contains a seed
  static Future<void> setClipboardClearEvent() async {
    if (eventSet) { return; }
    eventSet = true;
    await Future.delayed(Duration(minutes: 2), () {
      eventSet = false;
      Clipboard.getData("text/plain").then((data) {
        if (NanoSeeds.isValidSeed(data.text)) {
          Clipboard.setData(ClipboardData(text: ""));
        }
      });
    });
  }
}
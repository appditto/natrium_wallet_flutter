import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:nanodart/nanodart.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';

import 'package:quiver/strings.dart';
import 'package:validators/validators.dart';
import 'package:barcode_scan/barcode_scan.dart';

enum DataType { RAW, URL }

class UserDataUtil {
  static const MethodChannel _channel = const MethodChannel('fappchannel');
  static StreamSubscription<dynamic> setStream;

  static String _parseData(String data, DataType type) {
    data = data.trim();
    if (type == DataType.RAW) {
      return data;
    } else if (type == DataType.URL) {
      if (isIP(data)) {
        return data;
      } else if (isURL(data)) {
        return data;
      }
    }
    return null;
  }

  static Future<String> getClipboardText(DataType type) async {
    ClipboardData data = await Clipboard.getData("text/plain");
    if (data == null || data.text == null) {
      return null;
    }
    return _parseData(data.text, type);
  }

  static Future<String> getQRData(DataType type, OverlayTheme theme) async {
    UIUtil.cancelLockEvent();
    try {
      String data = await BarcodeScanner.scan(theme);
      if (isEmpty(data)) {
        return null;
      }
      return _parseData(data, type);
    } catch (e) {
      return null;
    }
  }

  static Future<void> setSecureClipboardItem(String value) async {
    if (Platform.isIOS) {
      final Map<String, dynamic> params = <String, dynamic>{
        'value': value,
      };
      await _channel.invokeMethod("setSecureClipboardItem", params);
    } else {
      // Set item in clipboard
      await Clipboard.setData(new ClipboardData(text: value));
      // Auto clear it after 2 minutes
      if (setStream != null) {
        setStream.cancel();
      }
      Future<dynamic> delayed = new Future.delayed(new Duration(minutes: 2));
      delayed.then((_) {
        return true;
      });
      setStream = delayed.asStream().listen((_) {
        Clipboard.getData("text/plain").then((data) {
          if (data != null && data.text != null && NanoSeeds.isValidSeed(data.text)) {
            Clipboard.setData(ClipboardData(text: ""));
          }
        });
      });
    }
  }
}
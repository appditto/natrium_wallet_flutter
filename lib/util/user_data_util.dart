import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nanodart/nanodart.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';

import 'package:quiver/strings.dart';
import 'package:validators/validators.dart';
import 'package:barcode_scan/barcode_scan.dart';

enum DataType { RAW, URL, MANTA_ADDRESS }

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
    } else if (type == DataType.MANTA_ADDRESS) {
      // Check if an address or manta result
      Address address = Address(data);
      if (address.isValid()) {
        return data;
      } else if (MantaWallet.parseUrl(data) != null) {
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

  static Future<String> getQRData(DataType type, BuildContext context) async {
    UIUtil.cancelLockEvent();
    try {
      String data = await BarcodeScanner.scan(StateContainer.of(context).curTheme.qrScanTheme);
      if (isEmpty(data)) {
        return null;
      }
      return _parseData(data, type);
    } catch (e) {
      if (e.code ==
          BarcodeScanner.CameraAccessDenied) {
        UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidPermissions, context);
      } else {
        UIUtil.showSnackbar(AppLocalization.of(context).qrUnknownError, context);
      }
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
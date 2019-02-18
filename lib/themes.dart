import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:local_auth/local_auth.dart';

class AppColors {
  // Some constants not themed
  static const overlay70 = Color(0xB3000000);
  static const overlay85 = Color(0xD9000000);
}

abstract class BaseTheme {
  Color primary;
  Color primary60;
  Color primary45;
  Color primary30;
  Color primary20;
  Color primary15;
  Color primary10;

  Color success;
  Color success60;
  Color success30;
  Color success15;
  Color successDark;
  Color successDark30;

  Color background;
  Color background40;
  Color background00;

  Color backgroundDark;
  Color backgroundDark00;

  Color backgroundDarkest;

  Color text;
  Color text60;
  Color text45;
  Color text30;
  Color text20;
  Color text15;
  Color text03;

  Color overlay20;
  Color overlay30;
  Color overlay50;
  Color overlay70;
  Color overlay80;
  Color overlay85;
  Color overlay90;

  Brightness brightness;
  SystemUiOverlayStyle statusBar;

  BoxShadow boxShadow;
  BoxShadow boxShadowButton;

  // QR scanner theme
  OverlayTheme qrScanTheme;
  // FP Dialog theme (android-only)
  FPDialogTheme fpTheme;
  // App icon (iOS only)
  AppIconEnum appIcon;
}

class NatriumTheme extends BaseTheme {
  static const brightBlue = Color(0xFFA3CDFF);
  static const brightBlue10 = Color(0x1AA3CDFF);
  static const brightBlue15 = Color(0x26A3CDFF);
  static const brightBlue20 = Color(0x33A3CDFF);
  static const brightBlue30 = Color(0x4DA3CDFF);
  static const brightBlue45 = Color(0x73A3CDFF);
  static const brightBlue60 = Color(0x99A3CDFF);

  static const green = Color(0xFF4AFFAE);
  static const green60 = Color(0x994AFFAE);
  static const green30 = Color(0x4D4AFFAE);
  static const green15 = Color(0x264AFFAE);
  static const greenDark = Color(0xFF18A264);
  static const greenDark30 = Color(0x4D18A264);

  static const blueishGreyLight = Color(0xFF1E2C3D);
  static const blueishGreyLight40 = Color(0x661E2C3D);
  static const blueishGreyLight00 = Color(0x001E2C3D);

  static const blueishGreyDark = Color(0xFF2A3A4D);
  static const blueishGreyDark00 = Color(0x002A3A4D);

  static const blueishGreyDarkest = Color(0xFF1E2C3D);

  static const white90 = Color(0xE6FFFFFF);
  static const white60 = Color(0x99FFFFFF);
  static const white45 = Color(0x73FFFFFF);
  static const white30 = Color(0x4DFFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white15 = Color(0x26FFFFFF);
  static const white03 = Color(0x08FFFFFF);

  static const black20 = Color(0x33000000);
  static const black30 = Color(0x4D000000);
  static const black50 = Color(0x80000000);
  static const black70 = Color(0xB3000000);
  static const black80 = Color(0xCC000000);
  static const black85 = Color(0xD9000000);
  static const black90 = Color(0xE6000000);

  Color primary = brightBlue;
  Color primary60 = brightBlue60;
  Color primary45 = brightBlue45;
  Color primary30 = brightBlue30;
  Color primary20 = brightBlue20;
  Color primary15 = brightBlue15;
  Color primary10 = brightBlue10;

  Color success = green;
  Color success60 = green60;
  Color success30 = green30;
  Color success15 = green15;
  Color successDark = greenDark;
  Color successDark30 = greenDark30;

  Color background = blueishGreyLight;
  Color background40 = blueishGreyLight40;
  Color background00 = blueishGreyLight00;

  Color backgroundDark = blueishGreyDark;
  Color backgroundDark00 = blueishGreyDark00;

  Color backgroundDarkest = blueishGreyDarkest;

  Color text = white90;
  Color text60 = white60;
  Color text45 = white45;
  Color text30 = white30;
  Color text20 = white20;
  Color text15 = white15;
  Color text03 = white03;

  Color overlay20 = black20;
  Color overlay30 = black20;
  Color overlay50 = black50;
  Color overlay70 = black70;
  Color overlay80 = black80;
  Color overlay85 = black85;
  Color overlay90 = black90;

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.NATRIUM;
  FPDialogTheme fpTheme = FPDialogTheme.NATRIUM;
  AppIconEnum appIcon = AppIconEnum.NATRIUM;
}

enum AppIconEnum { NATRIUM }
class AppIcon {
  static const _channel = const MethodChannel('fappchannel');

  static Future<void> setAppIcon(AppIconEnum iconToChange) async {
    if (!Platform.isIOS) {
      return null;
    }
    String iconStr = "natrium";
    switch (iconToChange) {
      case AppIconEnum.NATRIUM:
      default:
        iconStr = "natrium";
        break;
    }
    final Map<String, dynamic> params = <String, dynamic>{
     'icon': iconStr,
    };
    return await _channel.invokeMethod('changeIcon', params);
  }
}
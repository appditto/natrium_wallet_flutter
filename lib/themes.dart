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

  static const blueishGreyDark = Color(0xFF1E2C3D);
  static const blueishGreyDark40 = Color(0x661E2C3D);
  static const blueishGreyDark00 = Color(0x001E2C3D);

  static const blueishGreyLight = Color(0xFF2A3A4D);
  static const blueishGreyLight00 = Color(0x002A3A4D);

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

  Color background = blueishGreyDark;
  Color background40 = blueishGreyDark40;
  Color background00 = blueishGreyDark00;

  Color backgroundDark = blueishGreyLight;
  Color backgroundDark00 = blueishGreyLight00;

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

class TitaniumTheme extends BaseTheme {
  static const blueishGreen = Color(0xFF61C6AD);

  static const green = Color(0xFFB5ED88);

  static const greenDark = Color(0xFF5F893D);

  static const tealDark = Color(0xFF041920);

  static const tealLight = Color(0xFF052029);

  static const tealDarkest = Color(0xFF041920);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  Color primary = blueishGreen;
  Color primary60 = blueishGreen.withOpacity(0.6);
  Color primary45 = blueishGreen.withOpacity(0.45);
  Color primary30 = blueishGreen.withOpacity(0.3);
  Color primary20 = blueishGreen.withOpacity(0.2);
  Color primary15 = blueishGreen.withOpacity(0.15);
  Color primary10 = blueishGreen.withOpacity(0.1);

  Color success = green;
  Color success60 = green.withOpacity(0.6);
  Color success30 = green.withOpacity(0.3);
  Color success15 = green.withOpacity(0.15);

  Color successDark = greenDark;
  Color successDark30 = greenDark.withOpacity(0.3);

  Color background = tealDark;
  Color background40 = tealDark.withOpacity(0.4);
  Color background00 = tealDark.withOpacity(0.0);

  Color backgroundDark = tealLight;
  Color backgroundDark00 = tealLight.withOpacity(0.0);

  Color backgroundDarkest = tealDarkest;

  Color text = white.withOpacity(0.9);
  Color text60 = white.withOpacity(0.6);
  Color text45 = white.withOpacity(0.45);
  Color text30 = white.withOpacity(0.3);
  Color text20 = white.withOpacity(0.2);
  Color text15 = white.withOpacity(0.15);
  Color text03 = white.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.TITANIUM;
  FPDialogTheme fpTheme = FPDialogTheme.TITANIUM;
  AppIconEnum appIcon = AppIconEnum.TITANIUM;
}

class IndiumTheme extends BaseTheme {
  static const deepBlue = Color(0xFF0050BB);

  static const green = Color(0xFF00A873);

  static const greenLight = Color(0xFF9EEDD4);

  static const white = Color(0xFFFFFFFF);

  static const whiteishDark = Color(0xFFE8F0FA);

  static const grey = Color(0xFF454868);

  static const black = Color(0xFF000000);

  static const darkDeepBlue = Color(0xFF0050BB);

  Color primary = deepBlue;
  Color primary60 = deepBlue.withOpacity(0.6);
  Color primary45 = deepBlue.withOpacity(0.45);
  Color primary30 = deepBlue.withOpacity(0.3);
  Color primary20 = deepBlue.withOpacity(0.2);
  Color primary15 = deepBlue.withOpacity(0.15);
  Color primary10 = deepBlue.withOpacity(0.1);

  Color success = green;
  Color success60 = green.withOpacity(0.6);
  Color success30 = green.withOpacity(0.3);
  Color success15 = green.withOpacity(0.15);

  Color successDark = greenLight;
  Color successDark30 = greenLight.withOpacity(0.3);

  Color background = white;
  Color background40 = white.withOpacity(0.4);
  Color background00 = white.withOpacity(0.0);

  Color backgroundDark = white;
  Color backgroundDark00 = white.withOpacity(0.0);

  Color backgroundDarkest = whiteishDark;

  Color text = grey.withOpacity(0.9);
  Color text60 = grey.withOpacity(0.6);
  Color text45 = grey.withOpacity(0.45);
  Color text30 = grey.withOpacity(0.3);
  Color text20 = grey.withOpacity(0.2);
  Color text15 = grey.withOpacity(0.15);
  Color text03 = grey.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Brightness brightness = Brightness.light;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(
      color: darkDeepBlue.withOpacity(0.1),
      offset: Offset(0, 5),
      blurRadius: 15);
  BoxShadow boxShadowButton = BoxShadow(
      color: darkDeepBlue.withOpacity(0.2),
      offset: Offset(0, 5),
      blurRadius: 15);

  OverlayTheme qrScanTheme = OverlayTheme.INDIUM;
  FPDialogTheme fpTheme = FPDialogTheme.INDIUM;
  AppIconEnum appIcon = AppIconEnum.INDIUM;
}

enum AppIconEnum { NATRIUM, TITANIUM, INDIUM }
class AppIcon {
  static const _channel = const MethodChannel('fappchannel');

  static Future<void> setAppIcon(AppIconEnum iconToChange) async {
    if (!Platform.isIOS) {
      return null;
    }
    String iconStr = "natrium";
    switch (iconToChange) {
      case AppIconEnum.INDIUM:
        iconStr = "indium";
        break;
      case AppIconEnum.TITANIUM:
        iconStr = "titanium";
        break;
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
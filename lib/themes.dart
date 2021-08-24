import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

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
  Color text10;
  Color text05;
  Color text03;

  Color overlay20;
  Color overlay30;
  Color overlay50;
  Color overlay70;
  Color overlay80;
  Color overlay85;
  Color overlay90;

  Color barrier;
  Color barrierWeaker;
  Color barrierWeakest;
  Color barrierStronger;

  Color animationOverlayMedium;
  Color animationOverlayStrong;

  Brightness brightness;
  SystemUiOverlayStyle statusBar;

  BoxShadow boxShadow;
  BoxShadow boxShadowButton;

  // QR scanner theme
  OverlayTheme qrScanTheme;
  // App icon (iOS only)
  AppIconEnum appIcon;
}

class NatriumTheme extends BaseTheme {
  static const brightBlue = Color(0xFFA3CDFF);

  static const green = Color(0xFF4AFFAE);

  static const greenDark = Color(0xFF18A264);

  static const blueishGreyDark = Color(0xFF1E2C3D);

  static const blueishGreyLight = Color(0xFF2A3A4D);

  static const blueishGreyDarkest = Color(0xFF1E2C3D);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  Color primary = brightBlue;
  Color primary60 = brightBlue.withOpacity(0.6);
  Color primary45 = brightBlue.withOpacity(0.45);
  Color primary30 = brightBlue.withOpacity(0.3);
  Color primary20 = brightBlue.withOpacity(0.2);
  Color primary15 = brightBlue.withOpacity(0.15);
  Color primary10 = brightBlue.withOpacity(0.1);

  Color success = green;
  Color success60 = green.withOpacity(0.6);
  Color success30 = green.withOpacity(0.3);
  Color success15 = green.withOpacity(0.15);

  Color successDark = greenDark;
  Color successDark30 = greenDark.withOpacity(0.3);

  Color background = blueishGreyDark;
  Color background40 = blueishGreyDark.withOpacity(0.4);
  Color background00 = blueishGreyDark.withOpacity(0.0);

  Color backgroundDark = blueishGreyLight;
  Color backgroundDark00 = blueishGreyLight.withOpacity(0.0);

  Color backgroundDarkest = blueishGreyDarkest;

  Color text = white.withOpacity(0.9);
  Color text60 = white.withOpacity(0.6);
  Color text45 = white.withOpacity(0.45);
  Color text30 = white.withOpacity(0.3);
  Color text20 = white.withOpacity(0.2);
  Color text15 = white.withOpacity(0.15);
  Color text10 = white.withOpacity(0.1);
  Color text05 = white.withOpacity(0.05);
  Color text03 = white.withOpacity(0.03);

  Color overlay20 = black.withOpacity(0.2);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay90 = black.withOpacity(0.9);

  Color barrier = black.withOpacity(0.7);
  Color barrierWeaker = black.withOpacity(0.4);
  Color barrierWeakest = black.withOpacity(0.3);
  Color barrierStronger = black.withOpacity(0.85);

  Color animationOverlayMedium = black.withOpacity(0.7);
  Color animationOverlayStrong = black.withOpacity(0.85);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.NATRIUM;
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
  Color text10 = white.withOpacity(0.1);
  Color text05 = white.withOpacity(0.05);
  Color text03 = white.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Color barrier = black.withOpacity(0.7);
  Color barrierWeaker = black.withOpacity(0.4);
  Color barrierWeakest = black.withOpacity(0.3);
  Color barrierStronger = black.withOpacity(0.85);

  Color animationOverlayMedium = black.withOpacity(0.7);
  Color animationOverlayStrong = black.withOpacity(0.85);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.TITANIUM;
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
  Color text10 = grey.withOpacity(0.1);
  Color text05 = grey.withOpacity(0.05);
  Color text03 = grey.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.70);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Color barrier = black.withOpacity(0.7);
  Color barrierWeaker = black.withOpacity(0.4);
  Color barrierWeakest = black.withOpacity(0.3);
  Color barrierStronger = black.withOpacity(0.85);

  Color animationOverlayMedium = white.withOpacity(0.7);
  Color animationOverlayStrong = white.withOpacity(0.85);

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
  AppIconEnum appIcon = AppIconEnum.INDIUM;
}

class NeptuniumTheme extends BaseTheme {
  static const blue = Color(0xFF4A90E2);

  static const orange = Color(0xFFF9AE42);

  static const orangeDark = Color(0xFF9C671E);

  static const blueDark = Color(0xFF000034);

  static const blueLightish = Color(0xFF080840);

  static const blueDarkest = Color(0xFF000034);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  Color primary = blue;
  Color primary60 = blue.withOpacity(0.6);
  Color primary45 = blue.withOpacity(0.45);
  Color primary30 = blue.withOpacity(0.3);
  Color primary20 = blue.withOpacity(0.2);
  Color primary15 = blue.withOpacity(0.15);
  Color primary10 = blue.withOpacity(0.1);

  Color success = orange;
  Color success60 = orange.withOpacity(0.6);
  Color success30 = orange.withOpacity(0.3);
  Color success15 = orange.withOpacity(0.15);

  Color successDark = orangeDark;
  Color successDark30 = orangeDark.withOpacity(0.3);

  Color background = blueDark;
  Color background40 = blueDark.withOpacity(0.4);
  Color background00 = blueDark.withOpacity(0.0);

  Color backgroundDark = blueLightish;
  Color backgroundDark00 = blueLightish.withOpacity(0.0);

  Color backgroundDarkest = blueDarkest;

  Color text = white.withOpacity(0.9);
  Color text60 = white.withOpacity(0.6);
  Color text45 = white.withOpacity(0.45);
  Color text30 = white.withOpacity(0.3);
  Color text20 = white.withOpacity(0.2);
  Color text15 = white.withOpacity(0.15);
  Color text10 = white.withOpacity(0.1);
  Color text05 = white.withOpacity(0.05);
  Color text03 = white.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Color barrier = black.withOpacity(0.75);
  Color barrierWeaker = black.withOpacity(0.45);
  Color barrierWeakest = black.withOpacity(0.35);
  Color barrierStronger = black.withOpacity(0.9);

  Color animationOverlayMedium = black.withOpacity(0.75);
  Color animationOverlayStrong = black.withOpacity(0.9);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.NEPTUNIUM;
  AppIconEnum appIcon = AppIconEnum.NEPTUNIUM;
}

class ThoriumTheme extends BaseTheme {
  static const teal = Color(0xFF75F3FF);

  static const orange = Color(0xFFFFBA59);

  static const orangeDark = Color(0xFFBF8026);

  static const purpleDark = Color(0xFF200A40);

  static const purpleLight = Color(0xFF2A1052);

  static const purpleDarkest = Color(0xFF200A40);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  Color primary = teal;
  Color primary60 = teal.withOpacity(0.6);
  Color primary45 = teal.withOpacity(0.45);
  Color primary30 = teal.withOpacity(0.3);
  Color primary20 = teal.withOpacity(0.2);
  Color primary15 = teal.withOpacity(0.15);
  Color primary10 = teal.withOpacity(0.1);

  Color success = orange;
  Color success60 = orange.withOpacity(0.6);
  Color success30 = orange.withOpacity(0.3);
  Color success15 = orange.withOpacity(0.15);

  Color successDark = orangeDark;
  Color successDark30 = orangeDark.withOpacity(0.3);

  Color background = purpleDark;
  Color background40 = purpleDark.withOpacity(0.4);
  Color background00 = purpleDark.withOpacity(0.0);

  Color backgroundDark = purpleLight;
  Color backgroundDark00 = purpleLight.withOpacity(0.0);

  Color backgroundDarkest = purpleDarkest;

  Color text = white.withOpacity(0.9);
  Color text60 = white.withOpacity(0.6);
  Color text45 = white.withOpacity(0.45);
  Color text30 = white.withOpacity(0.3);
  Color text20 = white.withOpacity(0.2);
  Color text15 = white.withOpacity(0.15);
  Color text10 = white.withOpacity(0.1);
  Color text05 = white.withOpacity(0.05);
  Color text03 = white.withOpacity(0.03);

  Color overlay90 = black.withOpacity(0.9);
  Color overlay85 = black.withOpacity(0.85);
  Color overlay80 = black.withOpacity(0.8);
  Color overlay70 = black.withOpacity(0.7);
  Color overlay50 = black.withOpacity(0.5);
  Color overlay30 = black.withOpacity(0.3);
  Color overlay20 = black.withOpacity(0.2);

  Color barrier = black.withOpacity(0.7);
  Color barrierWeaker = black.withOpacity(0.4);
  Color barrierWeakest = black.withOpacity(0.3);
  Color barrierStronger = black.withOpacity(0.85);

  Color animationOverlayMedium = black.withOpacity(0.7);
  Color animationOverlayStrong = black.withOpacity(0.85);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(color: Colors.transparent);
  BoxShadow boxShadowButton = BoxShadow(color: Colors.transparent);

  OverlayTheme qrScanTheme = OverlayTheme.THORIUM;
  AppIconEnum appIcon = AppIconEnum.THORIUM;
}

class CarbonTheme extends BaseTheme {
  static const brightBlue = Color(0xFF99C1F0);

  static const green = Color(0xFF41E099);

  static const greenDark = Color(0xFF148A55);

  static const white = Color(0xFFFFFFFF);
  static const whiteish = Color(0xFFE9E9F2);

  static const black = Color(0xFF000000);
  static const blackBlueish = Color(0xFF0D1014);
  static const blackLighter = Color(0xFF0E0F0F);

  Color primary = brightBlue;
  Color primary60 = brightBlue.withOpacity(0.6);
  Color primary45 = brightBlue.withOpacity(0.45);
  Color primary30 = brightBlue.withOpacity(0.3);
  Color primary20 = brightBlue.withOpacity(0.2);
  Color primary15 = brightBlue.withOpacity(0.15);
  Color primary10 = brightBlue.withOpacity(0.1);

  Color success = green;
  Color success60 = green.withOpacity(0.6);
  Color success30 = green.withOpacity(0.3);
  Color success15 = green.withOpacity(0.15);

  Color successDark = greenDark;
  Color successDark30 = greenDark.withOpacity(0.3);

  Color background = black;
  Color background40 = black.withOpacity(0.4);
  Color background00 = black.withOpacity(0.0);

  Color backgroundDark = black;
  Color backgroundDark00 = black.withOpacity(0.0);

  Color backgroundDarkest = blackLighter;

  Color text = whiteish.withOpacity(0.9);
  Color text60 = whiteish.withOpacity(0.6);
  Color text45 = whiteish.withOpacity(0.45);
  Color text30 = whiteish.withOpacity(0.3);
  Color text20 = whiteish.withOpacity(0.2);
  Color text15 = whiteish.withOpacity(0.15);
  Color text10 = whiteish.withOpacity(0.1);
  Color text05 = whiteish.withOpacity(0.05);
  Color text03 = whiteish.withOpacity(0.03);

  Color overlay90 = blackLighter.withOpacity(0.9);
  Color overlay85 = blackLighter.withOpacity(0.85);
  Color overlay80 = blackLighter.withOpacity(0.8);
  Color overlay70 = blackLighter.withOpacity(0.7);
  Color overlay50 = blackLighter.withOpacity(0.5);
  Color overlay30 = blackLighter.withOpacity(0.3);
  Color overlay20 = blackLighter.withOpacity(0.2);

  Color barrier = blackBlueish.withOpacity(0.8);
  Color barrierWeaker = blackBlueish.withOpacity(0.7);
  Color barrierWeakest = blackBlueish.withOpacity(0.35);
  Color barrierStronger = blackBlueish.withOpacity(0.9);

  Color animationOverlayMedium = blackBlueish.withOpacity(0.8);
  Color animationOverlayStrong = blackBlueish.withOpacity(0.9);

  Brightness brightness = Brightness.dark;
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  BoxShadow boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 1,
  );
  BoxShadow boxShadowButton = BoxShadow(
    color: brightBlue.withOpacity(0.24),
    offset: Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  );

  OverlayTheme qrScanTheme = OverlayTheme.CARBON;
  AppIconEnum appIcon = AppIconEnum.CARBON;
}

enum AppIconEnum { NATRIUM, TITANIUM, INDIUM, NEPTUNIUM, THORIUM, CARBON }

class AppIcon {
  static const _channel = const MethodChannel('fappchannel');

  static Future<void> setAppIcon(AppIconEnum iconToChange) async {
    if (!Platform.isIOS) {
      return null;
    }
    String iconStr = "natrium";
    switch (iconToChange) {
      case AppIconEnum.THORIUM:
        iconStr = "thorium";
        break;
      case AppIconEnum.NEPTUNIUM:
        iconStr = "neptunium";
        break;
      case AppIconEnum.INDIUM:
        iconStr = "indium";
        break;
      case AppIconEnum.TITANIUM:
        iconStr = "titanium";
        break;
      case AppIconEnum.CARBON:
        iconStr = "carbon";
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

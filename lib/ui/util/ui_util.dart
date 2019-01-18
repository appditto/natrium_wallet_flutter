import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/ui/util/exceptions.dart';

enum ThreeLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS, SUCCESS_FULL }
enum OneLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS }

enum MonkeySize { SMALL, HOME_SMALL, NORMAL, LARGE }

class UIUtil {
  static Widget threeLineAddressText(String address, { ThreeLineAddressTextType type = ThreeLineAddressTextType.PRIMARY, String contactName }) {
    String stringPartOne = address.substring(0, 11);
    String stringPartTwo = address.substring(11, 22);
    String stringPartThree = address.substring(22, 44);
    String stringPartFour = address.substring(44, 58);
    String stringPartFive = address.substring(58, 64);
    switch (type) {
      case ThreeLineAddressTextType.PRIMARY60:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressPrimary60,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: KaliumStyles.TextStyleAddressText60,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: KaliumStyles.TextStyleAddressText60,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: KaliumStyles.TextStyleAddressText60,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressPrimary60,
                  ),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.PRIMARY:
        Widget contactWidget = contactName != null ? 
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: contactName,
              style: KaliumStyles.TextStyleAddressPrimary
            )
          ) : SizedBox();
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressPrimary,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressPrimary,
                  ),
                ],
              ),
            )
          ],
        );
        case ThreeLineAddressTextType.SUCCESS:
        Widget contactWidget = contactName != null ? 
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: contactName,
              style: KaliumStyles.TextStyleAddressSuccess
            )
          ) : SizedBox();
        return Column(
          children: <Widget>[
            contactWidget,
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                ],
              ),
            )
          ],
        );
        case ThreeLineAddressTextType.SUCCESS_FULL:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartThree,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                ],
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartFour,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                ],
              ),
            )
          ],
        );
      default:
        throw new UIException("Invalid threeLineAddressText Type $type");
    }
  }

  static Widget oneLineAddressText(String address, { OneLineAddressTextType type = OneLineAddressTextType.PRIMARY }) {
    String stringPartOne = address.substring(0, 11);
    String stringPartFive = address.substring(58, 64);
    switch (type) {
      case OneLineAddressTextType.PRIMARY60:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressPrimary60,
                  ),
                  TextSpan(
                    text: "...",
                    style: KaliumStyles.TextStyleAddressText60,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressPrimary60,
                  ),
                ],
              ),
            ),
          ],
        );
      case OneLineAddressTextType.PRIMARY:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressPrimary,
                  ),
                  TextSpan(
                    text: "...",
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressPrimary,
                  ),
                ],
              ),
            ),
          ],
        );
        case OneLineAddressTextType.SUCCESS:
        return Column(
          children: <Widget>[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: stringPartOne,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: "...",
                    style: KaliumStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: KaliumStyles.TextStyleAddressSuccess,
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        throw new UIException("Invalid oneLineAddressText Type $type");
    }
  }

  static Widget threeLineSeedText(String address, {TextStyle textStyle}) {
    textStyle = textStyle ?? KaliumStyles.TextStyleSeed;
    String stringPartOne = address.substring(0, 22);
    String stringPartTwo = address.substring(22, 44);
    String stringPartThree = address.substring(44, 64);
    return Column(
      children: <Widget>[
        Text(
          stringPartOne,
          style: textStyle,
        ),
        Text(
          stringPartTwo,
          style: textStyle,
        ),
        Text(
          stringPartThree,
          style: textStyle,
        ),
      ],
    );
  }

  static Widget showBlockExplorerWebview(BuildContext context, String hash) {
    return WebviewScaffold(
      url: KaliumLocalization.of(context).getBlockExplorerUrl(hash),
      appBar: new AppBar(
        backgroundColor: KaliumColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: KaliumColors.text),
      ),
    );
  }

  static Widget showAccountWebview(BuildContext context, String account) {
    return WebviewScaffold(
      url: KaliumLocalization.of(context).getAccountExplorerUrl(account),
      appBar: new AppBar(
        backgroundColor: KaliumColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: KaliumColors.text),
      ),
    );
  }

  static Future<File> downloadOrRetrieveMonkey(BuildContext context, String address, MonkeySize monkeySize) async {
    // Get expected path
    String dir = (await getApplicationDocumentsDirectory()).path;
    String prefix;
    // Compute size required in pixels
    int size = 1000;
    switch (monkeySize) {
      case MonkeySize.LARGE:
        prefix = "large_";
        size = (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt();
        break;
      case MonkeySize.NORMAL:
        prefix = "normal_";
        size = (smallScreen(context)?130:200 * MediaQuery.of(context).devicePixelRatio).toInt();
        break;
      case MonkeySize.SMALL:
        prefix = "small_";
        size = (smallScreen(context)?55:70 * MediaQuery.of(context).devicePixelRatio).toInt();
        break;
      case MonkeySize.HOME_SMALL:
        prefix = "home_";
        size = (90 * MediaQuery.of(context).devicePixelRatio).toInt();
        break;
    }
    String fileName = '$dir/$prefix$address.png';
    if (await File(fileName).exists()) {
      return File(fileName);
    }
    // Download monKey and return file
    http.Client client = http.Client();
    var req = await client.get(Uri.parse(
        KaliumLocalization.of(context).getMonkeyDownloadUrl(address, size: size)));
    var bytes = req.bodyBytes;
    File file = File(fileName);
    await file.writeAsBytes(bytes);
    return file;
  }

  static double drawerWidth(BuildContext context) {
    if (MediaQuery.of(context).size.width < 375)
      return MediaQuery.of(context).size.width * 0.94;
    else
      return MediaQuery.of(context).size.width * 0.85;
  }
}

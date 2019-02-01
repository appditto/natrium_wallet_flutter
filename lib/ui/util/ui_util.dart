import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/bus/rxbus.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/ui/util/exceptions.dart';

enum ThreeLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS, SUCCESS_FULL }
enum OneLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS }

enum MonkeySize { SMALL, HOME_SMALL, NORMAL, LARGE }

class UIUtil {
  static Widget threeLineAddressText(String address,
      {ThreeLineAddressTextType type = ThreeLineAddressTextType.PRIMARY,
      String contactName}) {
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
                    style: AppStyles.TextStyleAddressPrimary60,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.TextStyleAddressText60,
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
                    style: AppStyles.TextStyleAddressText60,
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
                    style: AppStyles.TextStyleAddressText60,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressPrimary60,
                  ),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.PRIMARY:
        Widget contactWidget = contactName != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: contactName,
                    style: AppStyles.TextStyleAddressPrimary))
            : SizedBox();
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
                    style: AppStyles.TextStyleAddressPrimary,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.TextStyleAddressText90,
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
                    style: AppStyles.TextStyleAddressText90,
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
                    style: AppStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressPrimary,
                  ),
                ],
              ),
            )
          ],
        );
      case ThreeLineAddressTextType.SUCCESS:
        Widget contactWidget = contactName != null
            ? RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: contactName,
                    style: AppStyles.TextStyleAddressSuccess))
            : SizedBox();
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
                    style: AppStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.TextStyleAddressText90,
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
                    style: AppStyles.TextStyleAddressText90,
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
                    style: AppStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressSuccess,
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
                    style: AppStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartTwo,
                    style: AppStyles.TextStyleAddressSuccess,
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
                    style: AppStyles.TextStyleAddressSuccess,
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
                    style: AppStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressSuccess,
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

  static Widget oneLineAddressText(String address,
      {OneLineAddressTextType type = OneLineAddressTextType.PRIMARY}) {
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
                    style: AppStyles.TextStyleAddressPrimary60,
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.TextStyleAddressText60,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressPrimary60,
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
                    style: AppStyles.TextStyleAddressPrimary,
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressPrimary,
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
                    style: AppStyles.TextStyleAddressSuccess,
                  ),
                  TextSpan(
                    text: "...",
                    style: AppStyles.TextStyleAddressText90,
                  ),
                  TextSpan(
                    text: stringPartFive,
                    style: AppStyles.TextStyleAddressSuccess,
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
    textStyle = textStyle ?? AppStyles.TextStyleSeed;
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
    cancelLockEvent();
    return WebviewScaffold(
      url: AppLocalization.of(context).getBlockExplorerUrl(hash),
      appBar: new AppBar(
        backgroundColor: AppColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
    );
  }

  static Widget showAccountWebview(BuildContext context, String account) {
    cancelLockEvent();
    return WebviewScaffold(
      url: AppLocalization.of(context).getAccountExplorerUrl(account),
      appBar: new AppBar(
        backgroundColor: AppColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
    );
  }

  static Widget showWebview(String url) {
    cancelLockEvent();
    return WebviewScaffold(
      url: url,
      appBar: new AppBar(
        backgroundColor: AppColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: AppColors.text),
      ),
    );
  }

  static Future<File> downloadOrRetrieveMonkey(
      BuildContext context, String address, MonkeySize monkeySize) async {
    // Get expected path
    String dir = (await getApplicationDocumentsDirectory()).path;
    String prefix;
    // Compute size required in pixels
    int size = 1000;
    switch (monkeySize) {
      case MonkeySize.LARGE:
        prefix = "large_";
        size = (MediaQuery.of(context).size.width *
                MediaQuery.of(context).devicePixelRatio)
            .toInt();
        break;
      case MonkeySize.NORMAL:
        prefix = "normal_";
        int multiplier = smallScreen(context) ? 130 : 200;
        size = (multiplier * MediaQuery.of(context).devicePixelRatio).toInt();
        break;
      case MonkeySize.SMALL:
        prefix = "small_";
        int multiplier = smallScreen(context) ? 55 : 70;
        size = (multiplier * MediaQuery.of(context).devicePixelRatio).toInt();
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
    var req = await client.get(Uri.parse(AppLocalization.of(context)
        .getMonkeyDownloadUrl(address, size: size)));
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

  static void showSnackbar(String content, BuildContext context) {
    showToastWidget(
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05, horizontal: 14),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          width: MediaQuery.of(context).size.width - 30,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color:AppColors.black80, offset: Offset(0, 15), blurRadius: 30, spreadRadius: -5),
            ],
          ),
          child: Text(
            content,
            style: AppStyles.TextStyleSnackbar,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      dismissOtherToast: true,
      duration: Duration(milliseconds: 2500),
    );
  }

 static StreamSubscription<dynamic> _lockDisableSub;

  static Future<void> cancelLockEvent() async {
    // Cancel auto-lock event, usually if we are launching another intent
    if (_lockDisableSub != null) {
      _lockDisableSub.cancel();
    }
    RxBus.post(true, tag: RX_DISABLE_LOCK_TIMEOUT_TAG);
    Future<dynamic> delayed = Future.delayed(Duration(seconds: 10));
    delayed.then((_) {
      return true;
    });
    _lockDisableSub = delayed.asStream().listen((_) {
      RxBus.post(false, tag: RX_DISABLE_LOCK_TIMEOUT_TAG);
    });
  }
}

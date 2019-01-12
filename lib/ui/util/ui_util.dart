import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/ui/util/exceptions.dart';

enum ThreeLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS }
enum OneLineAddressTextType { PRIMARY60, PRIMARY, SUCCESS }

class UIUtil {
  static Widget threeLineAddressText(String address, { ThreeLineAddressTextType type = ThreeLineAddressTextType.PRIMARY }) {
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

  static Widget showBlockExplorerWebview(String hash) {
    return WebviewScaffold(
      url: KaliumLocalization.BLOCK_EXPLORER_URL + hash,
      appBar: new AppBar(
        backgroundColor: KaliumColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: KaliumColors.text),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/localization.dart';

class UIUtil {
  static Widget threeLineAddressText(String address) {
    String stringPartOne = address.substring(0, 11);
    String stringPartTwo = address.substring(11, 22);
    String stringPartThree = address.substring(22, 44);
    String stringPartFour = address.substring(44, 58);
    String stringPartFive = address.substring(58, 64);
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

    return  WebviewScaffold(
      url: KaliumLocalization.BLOCK_EXPLORER_URL + hash,
      appBar: new AppBar(
        backgroundColor: KaliumColors.background,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: KaliumColors.text),
      ),
    );
  }
}
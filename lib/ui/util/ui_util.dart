import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

threeLineAddressBuilder(String address) {
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
              style: TextStyle(
                color: KaliumColors.primary60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
            TextSpan(
              text: stringPartTwo,
              style: TextStyle(
                color: KaliumColors.text60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
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
              style: TextStyle(
                color: KaliumColors.text60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
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
              style: TextStyle(
                color: KaliumColors.text60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
            TextSpan(
              text: stringPartFive,
              style: TextStyle(
                color: KaliumColors.primary60,
                fontSize: 14.0,
                height: 1.2,
                fontWeight: FontWeight.w100,
                fontFamily: 'OverpassMono',
              ),
            ),
          ],
        ),
      )
    ],
  );
}
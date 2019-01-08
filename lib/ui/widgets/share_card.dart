
import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

class ShareCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.0,
      width: 964,
      decoration: BoxDecoration(
       color: KaliumColors.backgroundDark,
       borderRadius: BorderRadius.circular(50.0),
      ),
      child: Container(
        margin: EdgeInsets.only(left: 50, right: 50, top:55, bottom: 45),
        constraints: BoxConstraints.expand(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Monkey QR
            Container(
              height: 400,
              width: 420,
              color: KaliumColors.primary,
            ),
            // Banano logo, address, ticker and website
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Banano Logo
                Container(
                  width: 388,
                  height: 60,
                  color: KaliumColors.primary,
                ),
                // Address
                Container(
                  width: 388,
                  height: 200,
                  color: KaliumColors.primary,
                ),
                // Ticker & Website
                Container(
                  width: 388,
                  height: 50,
                  color: KaliumColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';

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
                Column(
                  children: <Widget>[
                    Container(
                      width: 388,
                      height: 50,
                      color: KaliumColors.primary,
                      child: AutoSizeText(
                        "ban_1yekta1u3ymi", 
                        minFontSize: 1.0,
                        stepGranularity: 0.1,
                        style: TextStyle(
                          color: KaliumColors.background,
                          fontFamily: "OverpassMono",
                        ),

                      ),
                    ),
                    Container(
                      width: 388,
                      height: 50,
                      color: KaliumColors.primary,
                      child: AutoSizeText(
                        "s5tji4jxpr4iz8a9", 
                        minFontSize: 1.0,
                        stepGranularity: 0.1,
                        style: TextStyle(
                          color: KaliumColors.background,
                          fontFamily: "OverpassMono",
                        ),

                      ),
                    ),
                    Container(
                      width: 388,
                      height: 50,
                      color: KaliumColors.primary,
                      child: AutoSizeText(
                        "bp4bjoz5qdw3wstb", 
                        minFontSize: 1.0,
                        stepGranularity: 0.1,
                        style: TextStyle(
                          color: KaliumColors.background,
                          fontFamily: "OverpassMono",
                        ),

                      ),
                    ),
                    Container(
                      width: 388,
                      height: 50,
                      color: KaliumColors.primary,
                      child: AutoSizeText(
                        "ub3wgxwi3nfuuyek", 
                        minFontSize: 1.0,
                        stepGranularity: 0.1,
                        style: TextStyle(
                          color: KaliumColors.background,
                          fontFamily: "OverpassMono",
                        ),

                      ),
                    ),
                  ],
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
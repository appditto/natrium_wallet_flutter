
import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';

class ShareCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 125.0,
      width: 241.0,
      decoration: BoxDecoration(
       color: KaliumColors.backgroundDark,
       borderRadius: BorderRadius.circular(12.5),
      ),
      child: Container(
        margin: EdgeInsets.only(left: 12.5, right: 12.5, top:13.75, bottom: 11.25),
        constraints: BoxConstraints.expand(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Monkey QR
            Container(
              height: 100.0,
              width: 105.0,
              color: KaliumColors.primary,
            ),
            // Banano logo, address, ticker and website
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Banano Logo
                Container(
                  width: 97.0,
                  height: 15.0,
                  color: KaliumColors.primary,
                ),
                // Address
                Column(
                  children: <Widget>[
                    Container(
                      width: 97.0,
                      height: 12.5,
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
                      width: 97.0,
                      height: 12.5,
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
                      width: 97.0,
                      height: 12.5,
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
                      width: 97.0,
                      height: 12.5,
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
                  width: 97.0,
                  height: 12.5,
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
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';

class KaliumShareCard extends StatefulWidget {
  GlobalKey key;

  KaliumShareCard(this.key);

  @override
  _KaliumShareCardState createState() => _KaliumShareCardState(key);
}

class _KaliumShareCardState extends State<KaliumShareCard> {
  GlobalKey globalKey;

  _KaliumShareCardState(this.globalKey);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        height: 125.0,
        width: 241.0,
        decoration: BoxDecoration(
          color: KaliumColors.green,
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Container(
          color: Colors.pink,
          margin: EdgeInsets.only(
              left: 12.5, right: 12.5, top: 13.75, bottom: 11.25),
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
                          StateContainer.of(context).wallet.address.substring(0, 16),
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
                          StateContainer.of(context).wallet.address.substring(16, 32),
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
                          StateContainer.of(context).wallet.address.substring(32, 48),
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
                          StateContainer.of(context).wallet.address.substring(48),
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
      ),
    );
  }
}
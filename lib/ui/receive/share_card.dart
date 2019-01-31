import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KaliumShareCard extends StatefulWidget {
  final GlobalKey key;
  final Widget monkeySvg;
  final Widget logoSvg;

  KaliumShareCard(this.key, this.monkeySvg, this.logoSvg);

  @override
  _KaliumShareCardState createState() =>
      _KaliumShareCardState(key, monkeySvg, logoSvg);
}

class _KaliumShareCardState extends State<KaliumShareCard> {
  GlobalKey globalKey;
  Widget monkeySvg;
  Widget logoSvg;

  _KaliumShareCardState(
      this.globalKey, this.monkeySvg, this.logoSvg);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        height: 125,
        width: 241,
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Container(
          margin:
              EdgeInsets.only(left: 12.5, right: 12.5, top: 12.5, bottom: 12.5),
          constraints: BoxConstraints.expand(),
          // The main row that holds monkeyQR, Banano logo, the address, ticker and the website text
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // A container for monkeyQR
              Container(
                width: 105,
                height: 100.0,
                child: Stack(
                  children: <Widget>[
                    // Background/border part of monkeyQR
                    Center(
                      child: Container(
                        width: 105,
                        height: 100.0,
                        child: monkeySvg,
                      ),
                    ),
                    // Actual QR part of the monkeyQR
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 26.25),
                        child: QrImage(
                          padding: EdgeInsets.all(0.0),
                          size: 50.3194,
                          data: StateContainer.of(context).wallet.address,
                          version: 6,
                          errorCorrectionLevel: QrErrorCorrectLevel.Q,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // A column for Banano logo, address, ticker and website text
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Banano Logo
                  Container(
                    width: 97,
                    height: 15,
                    child: logoSvg,
                  ),
                  // Address
                  Column(
                    children: <Widget>[
                      // First row of the address
                      Row(
                        children: <Widget>[
                          // Yellow part of the first row
                          Container(
                            width: 66.6875,
                            height: 12.5,
                            child: AutoSizeText(
                              StateContainer.of(context)
                                  .wallet
                                  .address
                                  .substring(0, 11),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                              ),
                              minFontSize: 1.0,
                              stepGranularity: 0.1,
                            ),
                          ),
                          // White part of the first row
                          Container(
                            width: 30.3125,
                            height: 12.5,
                            child: AutoSizeText(
                              StateContainer.of(context)
                                  .wallet
                                  .address
                                  .substring(11, 16),
                              minFontSize: 1.0,
                              stepGranularity: 0.1,
                              style: TextStyle(
                                color: AppColors.text,
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Second row of the address
                      Container(
                        width: 97,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context)
                              .wallet
                              .address
                              .substring(16, 32),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: AppColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      // Third row of the address
                      Container(
                        width: 97,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context)
                              .wallet
                              .address
                              .substring(32, 48),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: AppColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      // Fourth(last) row of the address
                      Row(
                        children: <Widget>[
                          // White part of the first row
                          Container(
                            width: 60.625,
                            height: 12.5,
                            child: AutoSizeText(
                              StateContainer.of(context)
                                  .wallet
                                  .address
                                  .substring(48, 58),
                              minFontSize: 1.0,
                              stepGranularity: 0.1,
                              style: TextStyle(
                                color: AppColors.text,
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                          // Yellow part of the first row
                          Container(
                            width: 36.375,
                            height: 12.5,
                            child: AutoSizeText(
                              StateContainer.of(context)
                                  .wallet
                                  .address
                                  .substring(58, 64),
                              minFontSize: 1.0,
                              stepGranularity: 0.1,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontFamily: "OverpassMono",
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Ticker & Website
                  Container(
                    width: 97,
                    height: 13,
                    child: AutoSizeText(
                      "\$BAN      BANANO.CC",
                      minFontSize: 1.0,
                      stepGranularity: 0.1,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: "NunitoSans",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
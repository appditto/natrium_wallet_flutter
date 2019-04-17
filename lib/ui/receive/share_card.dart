import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/themes.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AppShareCard extends StatefulWidget {
  final GlobalKey key;
  final Widget qrSVG;
  final Widget logoSvg;

  AppShareCard(this.key, this.qrSVG, this.logoSvg);

  @override
  _AppShareCardState createState() => _AppShareCardState(key, qrSVG, logoSvg);
}

class _AppShareCardState extends State<AppShareCard> {
  GlobalKey globalKey;
  Widget qrSVG;
  Widget logoSvg;

  _AppShareCardState(this.globalKey, this.qrSVG, this.logoSvg);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        height: 125,
        width: 235,
        decoration: BoxDecoration(
          color: StateContainer.of(context).curTheme.backgroundDark,
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Container(
          margin: EdgeInsets.only(left: 12.5, right: 12.5, top: 12.5),
          constraints: BoxConstraints.expand(),
          // The main row that holds QR, logo, the address, ticker and the website text
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // A container for QR
              Container(
                margin: EdgeInsets.only(bottom: 12.5),
                width: 100,
                height: 100.0,
                child: Stack(
                  children: <Widget>[
                    // Background QR
                    Center(
                      child: Container(
                        width: 91.954,
                        height: 91.954,
                        child: qrSVG,
                      ),
                    ),
                    // Actual QR part of the QR
                    Center(
                      child: Container(
                        child: QrImage(
                          padding: EdgeInsets.all(0.0),
                          size: 60,
                          data: StateContainer.of(context).wallet.address,
                          version: 6,
                          errorCorrectionLevel: QrErrorCorrectLevel.Q,
                        ),
                      ),
                    ),
                    // Outer Ring
                    Center(
                      child: Container(
                        width:
                            (StateContainer.of(context).curTheme is IndiumTheme)
                                ? 95
                                : 100,
                        height:
                            (StateContainer.of(context).curTheme is IndiumTheme)
                                ? 95
                                : 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              width: 1.3913),
                        ),
                      ),
                    ),
                    // Logo Background White
                    Center(
                      child: Container(
                        width: 23.88,
                        height: 23.88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Logo Background Primary
                    Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Logo
                    Center(
                      child: Container(
                        height: 5.333333,
                        child: AutoSizeText(
                          "",
                          style: TextStyle(
                            fontFamily: "AppIcons",
                            color: StateContainer.of(context)
                                .curTheme
                                .backgroundDark,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          minFontSize: 0.1,
                          stepGranularity: 0.1,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // A column for logo, address, ticker and website text
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  Container(
                    width: 96,
                    height: 20,
                    margin: EdgeInsets.only(left: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Currency Icon
                        Container(
                          width: 29,
                          child: AutoSizeText(
                            "  ",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontFamily: "AppIcons",
                              fontWeight: FontWeight.w500,
                            ),
                            minFontSize: 0.1,
                            stepGranularity: 0.1,
                            maxLines: 1,
                          ),
                        ),
                        Container(
                          width: 60,
                          margin: EdgeInsets.only(top: 1),
                          child: AutoSizeText(
                            "NANO",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontFamily: "Comfortaa",
                              fontWeight: FontWeight.w300,
                              fontSize: 40,
                              letterSpacing: 1.5,
                            ),
                            minFontSize: 0.1,
                            stepGranularity: 0.1,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Address
                  Container(
                    padding: Platform.isIOS
                        ? EdgeInsets.only(bottom: 7)
                        : EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        // First row of the address
                        Container(
                          width: 97,
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                // Primary part of the first row
                                TextSpan(
                                  text: StateContainer.of(context)
                                      .wallet
                                      .address
                                      .substring(0, 12),
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: Platform.isIOS?0.9:1.2,
                                  ),
                                ),
                                TextSpan(
                                  text: StateContainer.of(context)
                                      .wallet
                                      .address
                                      .substring(12, 16),
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: Platform.isIOS?0.9:1.2,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            style: TextStyle(
                              fontSize: 50.0,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              height: Platform.isIOS?0.9:1.2,
                            ),
                          ),
                        ),
                        // Second row of the address
                        Container(
                          width: 97,
                          child: AutoSizeText(
                            StateContainer.of(context)
                                .wallet
                                .address
                                .substring(16, 32),
                            minFontSize: 1.0,
                            stepGranularity: 0.1,
                            maxFontSize: 50,
                            maxLines: 1,
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              fontSize: 50,
                              height: Platform.isIOS?0.9:1.2,
                            ),
                          ),
                        ),
                        // Third row of the address
                        Container(
                          width: 97,
                          child: AutoSizeText(
                            StateContainer.of(context)
                                .wallet
                                .address
                                .substring(32, 48),
                            minFontSize: 1.0,
                            stepGranularity: 0.1,
                            maxFontSize: 50,
                            maxLines: 1,
                            style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              fontSize: 50,
                              height: Platform.isIOS?0.9:1.2,
                            ),
                          ),
                        ),
                        // Fourth(last) row of the address
                        Container(
                          width: 97,
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                // Text colored part of the last row
                                TextSpan(
                                  text: StateContainer.of(context)
                                      .wallet
                                      .address
                                      .substring(48, 59),
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: Platform.isIOS?0.9:1.2,
                                  ),
                                ),
                                // Primary colored part of the last row
                                TextSpan(
                                  text: StateContainer.of(context)
                                      .wallet
                                      .address
                                      .substring(59),
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    fontFamily: "OverpassMono",
                                    fontWeight: FontWeight.w100,
                                    fontSize: 50.0,
                                    height: Platform.isIOS?0.9:1.2,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            style: TextStyle(
                              fontSize: 50,
                              fontFamily: "OverpassMono",
                              fontWeight: FontWeight.w100,
                              height: Platform.isIOS?0.9:1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ticker & Website
                  Container(
                    width: 97,
                    margin: EdgeInsets.only(bottom: 12.5),
                    child: AutoSizeText(
                      "\$NANO      NANO.ORG",
                      minFontSize: 0.1,
                      stepGranularity: 0.1,
                      maxLines: 1,
                      style: TextStyle(
                        color: StateContainer.of(context).curTheme.primary,
                        fontFamily: "Comfortaa",
                        fontWeight: FontWeight.w400,
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

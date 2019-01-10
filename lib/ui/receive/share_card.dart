import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class KaliumShareCard extends StatefulWidget {
  GlobalKey key;

  KaliumShareCard(this.key);

  @override
  _KaliumShareCardState createState() => _KaliumShareCardState(key);
}

class _KaliumShareCardState extends State<KaliumShareCard> {
  GlobalKey globalKey;
  Widget _sharecardBananoLogo = new SvgPicture.asset('assets/sharecard_bananologo.svg');
  Widget _sharecardTickerWebsite = new SvgPicture.asset('assets/sharecard_tickerwebsite.svg');
  Widget _monkeyQRBackground = new SvgPicture.asset('assets/monkeyQR.svg');
  _KaliumShareCardState(this.globalKey);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: globalKey,
      child: Container(
        height: 125.0,
        width: 241.0,
        decoration: BoxDecoration(
          color: KaliumColors.backgroundDark,
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Container(
          margin: EdgeInsets.only(
              left: 12.5, right: 12.5, top: 12.5, bottom: 12.5),
          constraints: BoxConstraints.expand(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Monkey QR
              Container(
                height: 100.0,
                width: 105.0,
                child: Stack(
                      children: <Widget>[
                        Center(
                          child: Container(
                            width: 105,
                            height: 100,
                            child: _monkeyQRBackground,
                          ),
                        ),
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
              // Banano logo, address, ticker and website
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Banano Logo
                  Container(
                    width: 97.0,
                    height: 15.0,
                    child: _sharecardBananoLogo,
                  ),
                  // Address
                  Column(
                    children: <Widget>[
                      Container(
                        width: 97.0,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context).wallet.address.substring(0, 16),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: KaliumColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Container(
                        width: 97.0,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context).wallet.address.substring(16, 32),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: KaliumColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Container(
                        width: 97.0,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context).wallet.address.substring(32, 48),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: KaliumColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      Container(
                        width: 97.0,
                        height: 12.5,
                        child: AutoSizeText(
                          StateContainer.of(context).wallet.address.substring(48),
                          minFontSize: 1.0,
                          stepGranularity: 0.1,
                          style: TextStyle(
                            color: KaliumColors.text,
                            fontFamily: "OverpassMono",
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Ticker & Website
                  Container(
                    width: 97.0,
                    height: 12.5,
                    child: _sharecardTickerWebsite,
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
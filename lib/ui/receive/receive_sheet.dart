import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/receive/share_card.dart';
import 'package:kalium_wallet_flutter/model/wallet.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KaliumReceiveSheet {
  KaliumWallet _wallet;

  GlobalKey shareCardKey;
  Widget kaliumShareCard;
  ByteData shareImageData;
  Widget monkeySVGBorder;
  Widget shareCardLogoSvg;
  Widget shareCardTickerSvg;

  Widget qrCode;

  KaliumReceiveSheet(Widget qrWidget) {
    // Create our SVG-heavy things in the constructor because they are slower operations
    monkeySVGBorder = SvgPicture.asset('assets/monkeyQR.svg');
    shareCardLogoSvg = SvgPicture.asset('assets/sharecard_bananologo.svg');
    // Share card initialization
    shareCardKey = GlobalKey();
    kaliumShareCard = Container(
      child: KaliumShareCard(shareCardKey, monkeySVGBorder, shareCardLogoSvg),
      alignment: Alignment(0.0, 0.0),
    );
    qrCode = qrWidget;
  }

  // Address copied items
  // Current state references
  bool _showShareCard;
  bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  Future<Uint8List> _capturePng() async {
    if (shareCardKey != null && shareCardKey.currentContext != null) {
      RenderRepaintBoundary boundary =
          shareCardKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData.buffer.asUint8List();
    } else {
      return null;
    }
  }

  mainBottomSheet(BuildContext context) {
    _wallet = StateContainer.of(context).wallet;
    // Set initial state of copy button
    _addressCopied = false;
    double devicewidth = MediaQuery.of(context).size.width;

    _showShareCard = false;

    KaliumSheets.showKaliumHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: <Widget>[
                // A row for the address text and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Close Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(KaliumIcons.close,
                            size: 16, color: AppColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                    //Container for the address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: UIUtil.threeLineAddressText(_wallet.address,
                          type: ThreeLineAddressTextType.PRIMARY60),
                    ),
                    //Empty SizedBox
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),

                //MonkeyQR which takes all the available space left from the buttons & address text
                Expanded(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        _showShareCard ? kaliumShareCard : SizedBox(),
                        // This is for hiding the share card
                        Center(
                          child: Container(
                            width: 260,
                            height: 150,
                            color: AppColors.backgroundDark,
                          ),
                        ),
                        // Background/border part the monkeyQR
                        Center(
                          child: Container(
                            width: devicewidth / 1.5,
                            child: monkeySVGBorder,
                          ),
                        ),
                        // Actual QR part of the monkeyQR
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: devicewidth / 6),
                            child: qrCode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with Copy Address and Share Address buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
                          // Share Address Button
                          _addressCopied ? KaliumButtonType.SUCCESS : KaliumButtonType.PRIMARY,
                          _addressCopied ? AppLocalization.of(context).addressCopied : AppLocalization.of(context).copyAddress,
                          Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                            Clipboard.setData(
                                new ClipboardData(text: _wallet.address));
                            setState(() {
                              // Set copied style
                              _addressCopied = true;
                            });
                            if (_addressCopiedTimer != null) {
                              _addressCopiedTimer.cancel();
                            }
                            _addressCopiedTimer = new Timer(
                                const Duration(milliseconds: 800), () {
                              setState(() {
                                _addressCopied = false;
                              });
                            });
                          }
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
                            // Share Address Button
                            KaliumButtonType.PRIMARY_OUTLINE,
                            _showShareCard ? "Loading" : AppLocalization.of(context).addressShare,
                            Dimens.BUTTON_BOTTOM_DIMENS,
                            disabled: _showShareCard, onPressed: () {
                          String receiveCardFileName = "share_${StateContainer.of(context).wallet.address}.png";
                          getApplicationDocumentsDirectory().then((directory) {
                            bool doCapture = true;
                            String filePath = "${directory.path}/$receiveCardFileName";
                            File f = File(filePath);
                            if (f.existsSync()) {
                              try {
                                Share.shareFile(f, text: StateContainer.of(context).wallet.address);
                                doCapture = false;
                              } catch (e) {
                                doCapture = true;
                              }
                            }
                            if (doCapture) {
                              setState(() {
                                _showShareCard = true;
                              });
                              Future.delayed(new Duration(milliseconds: 300), () {
                                if (_showShareCard) {
                                  _capturePng().then((byteData) {
                                    if (byteData != null) {
                                      f.writeAsBytes(byteData).then((file) {
                                        Share.shareFile(file, text: StateContainer.of(context).wallet.address);
                                      });
                                    } else {
                                      // TODO - show a something went wrong message
                                    }
                                    setState(() {
                                      _showShareCard = false;
                                    });
                                  });
                                }
                              });
                            }
                          });
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }
}

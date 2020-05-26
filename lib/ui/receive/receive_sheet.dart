import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:natrium_wallet_flutter/themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/receive/share_card.dart';
import 'package:natrium_wallet_flutter/model/wallet.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

class AppReceiveSheet {
  AppWallet _wallet;

  GlobalKey shareCardKey;
  Widget appShareCard;
  ByteData shareImageData;
  Widget qrSVGBorder;
  Widget shareCardLogoSvg;
  Widget shareCardTickerSvg;

  Widget qrCode;
  Widget qrWidget;

  AppReceiveSheet(this.qrWidget);

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
    // Create our SVG-heavy things in the constructor because they are slower operations
    qrSVGBorder = SvgPicture.asset('assets/QR.svg');
    shareCardLogoSvg = SvgPicture.asset('assets/sharecard_logo.svg');
    // Share card initialization
    shareCardKey = GlobalKey();
    appShareCard = Container(
      child: AppShareCard(shareCardKey, qrSVGBorder, shareCardLogoSvg),
      alignment: AlignmentDirectional(0.0, 0.0),
    );
    qrCode = qrWidget;

    _showShareCard = false;

    AppSheets.showAppHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
                minimum: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.035),
                child: Column(
                  children: <Widget>[
                    // A row for the address text and close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        //Empty SizedBox
                        SizedBox(
                          width: 60,
                          height: 60,
                        ),
                        //Container for the address text and sheet handle
                        Column(
                          children: <Widget>[
                            // Sheet handle
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              height: 5,
                              width: MediaQuery.of(context).size.width * 0.15,
                              decoration: BoxDecoration(
                                color:
                                    StateContainer.of(context).curTheme.text10,
                                borderRadius: BorderRadius.circular(100.0),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 15.0),
                              child: UIUtil.threeLineAddressText(
                                  context, _wallet.address,
                                  type: ThreeLineAddressTextType.PRIMARY60),
                            ),
                          ],
                        ),
                        //Empty SizedBox
                        SizedBox(
                          width: 60,
                          height: 60,
                        ),
                      ],
                    ),

                    // QR which takes all the available space left from the buttons & address text
                    Expanded(
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            _showShareCard ? appShareCard : SizedBox(),
                            // This is for hiding the share card
                            Center(
                              child: Container(
                                width: 260,
                                height: 150,
                                color: StateContainer.of(context)
                                    .curTheme
                                    .backgroundDark,
                              ),
                            ),
                            // Background/border part the QR
                            Center(
                              child: Container(
                                width: devicewidth / 1.74,
                                child: qrSVGBorder,
                              ),
                            ),
                            // Actual QR part of the QR
                            Center(
                              child: Container(
                                height: devicewidth / 2.65,
                                width: devicewidth / 2.65,
                                child: qrCode,
                              ),
                            ),
                            // Outer ring
                            Center(
                              child: Container(
                                width: (StateContainer.of(context).curTheme
                                        is IndiumTheme)
                                    ? devicewidth / 1.68
                                    : devicewidth / 1.6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      width: devicewidth / 110),
                                ),
                              ),
                            ),
                            // Logo Background White
                            Center(
                              child: Container(
                                width: devicewidth / 6,
                                height: devicewidth / 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    width: (StateContainer.of(context).curTheme
                                            is IndiumTheme)
                                        ? devicewidth / 110
                                        : devicewidth / 150,
                                    color: (StateContainer.of(context).curTheme
                                            is IndiumTheme)
                                        ? StateContainer.of(context)
                                            .curTheme
                                            .backgroundDark
                                        : StateContainer.of(context)
                                            .curTheme
                                            .primary,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: (StateContainer.of(context)
                                              .curTheme is IndiumTheme)
                                          ? devicewidth / 150
                                          : devicewidth / 110,
                                      color: (StateContainer.of(context)
                                              .curTheme is IndiumTheme)
                                          ? StateContainer.of(context)
                                              .curTheme
                                              .primary
                                          : StateContainer.of(context)
                                              .curTheme
                                              .backgroundDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // nnnnn
                            Center(
                              child: Container(
                                width: devicewidth / 6.25,
                                height: devicewidth / 6.25,
                                margin: EdgeInsetsDirectional.only(
                                    top: devicewidth / 110),
                                child: SvgPicture.network(
                                    'https://natricon.com/api/v1/nano?svc=natrium&outline=true&outlineColor=white&address=' +
                                        StateContainer.of(context)
                                            .selectedAccount
                                            .address,
                                    placeholderBuilder:
                                        (BuildContext context) => Container(
                                              child: FlareActor(
                                                "assets/ntr_placeholder_animation.flr",
                                                animation: "main",
                                                fit: BoxFit.contain,
                                                color:
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .primary,
                                              ),
                                            )),
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
                            AppButton.buildAppButton(
                                context,
                                // Share Address Button
                                _addressCopied
                                    ? AppButtonType.SUCCESS
                                    : AppButtonType.PRIMARY,
                                _addressCopied
                                    ? AppLocalization.of(context).addressCopied
                                    : AppLocalization.of(context).copyAddress,
                                Dimens.BUTTON_TOP_DIMENS, onPressed: () {
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
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                                context,
                                // Share Address Button
                                AppButtonType.PRIMARY_OUTLINE,
                                AppLocalization.of(context).addressShare,
                                Dimens.BUTTON_BOTTOM_DIMENS,
                                disabled: _showShareCard, onPressed: () {
                              String receiveCardFileName =
                                  "share_${StateContainer.of(context).wallet.address}.png";
                              getApplicationDocumentsDirectory()
                                  .then((directory) {
                                String filePath =
                                    "${directory.path}/$receiveCardFileName";
                                File f = File(filePath);
                                setState(() {
                                  _showShareCard = true;
                                });
                                Future.delayed(new Duration(milliseconds: 50),
                                    () {
                                  if (_showShareCard) {
                                    _capturePng().then((byteData) {
                                      if (byteData != null) {
                                        f.writeAsBytes(byteData).then((file) {
                                          UIUtil.cancelLockEvent();
                                          Share.shareFile(file,
                                              text: StateContainer.of(context)
                                                  .wallet
                                                  .address);
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
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ));
          });
        });
  }
}

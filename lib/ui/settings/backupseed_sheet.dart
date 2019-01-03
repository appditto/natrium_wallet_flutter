import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumSeedBackupSheet {
  // Seed copied state information
  static const TextStyle _initialSeedStyle = KaliumStyles.TextStyleSeed;
  String _seed;
  TextStyle _seedCopiedStyle;
  Timer _seedCopiedTimer;
  var _seedCopiedColor;

  mainBottomSheet(BuildContext context) {
    Vault.inst.getSeed().then((result) {
      _seed = result;
      // Set initial seed copy state
      _seedCopiedStyle = _initialSeedStyle;
      _seedCopiedColor = Colors.transparent;
      showKaliumHeightEightSheet(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //A container for the header
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "SEED",
                            style: KaliumStyles.TextStyleHeader,
                          ),
                        ],
                      ),
                    ),

                    //A container for the paragraph and seed
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 35, bottom: 35),
                        child: Column(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(left: 50, right: 50),
                                child: Text(
                                  "Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
                                  style: KaliumStyles.TextStyleParagraph,
                                )),
                            new GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    new ClipboardData(text: _seed));
                                setState(() {
                                  _seedCopiedStyle =
                                      KaliumStyles.TextStyleSeedGreen;
                                  _seedCopiedColor = KaliumColors.success;
                                });
                                if (_seedCopiedTimer != null) {
                                  _seedCopiedTimer.cancel();
                                }
                                _seedCopiedTimer = new Timer(
                                    const Duration(milliseconds: 800), () {
                                  setState(() {
                                    _seedCopiedStyle = _initialSeedStyle;
                                    _seedCopiedColor = Colors.transparent;
                                  });
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 25),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      color: KaliumColors.backgroundDarkest,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: threeLineSeedText(_seed,
                                        textStyle: _seedCopiedStyle),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text('Seed Copied To Clipboard',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: _seedCopiedColor,
                                          fontFamily: 'NunitoSans',
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //A row with close button
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                          KaliumButtonType.PRIMARY_OUTLINE,
                          'Close',
                          Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
          });
    });
  }
}

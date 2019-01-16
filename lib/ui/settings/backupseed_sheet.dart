import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumSeedBackupSheet {
  // Seed copied state information
  bool _seedCopied;
  String _seed;
  Timer _seedCopiedTimer;

  mainBottomSheet(BuildContext context) {
    Vault.inst.getSeed().then((result) {
      _seed = result;
      // Set initial seed copy state
      _seedCopied = false;
      KaliumSheets.showKaliumHeightEightSheet(
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
                            KaliumLocalization.of(context).seed.toUpperCase(),
                            style: KaliumStyles.textStyleHeader(context),
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
                                  KaliumLocalization.of(context).seedBackupInfo,
                                  style: KaliumStyles.TextStyleParagraph,
                                )),
                            new GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    new ClipboardData(text: _seed));
                                setState(() {
                                  _seedCopied = true;
                                });
                                if (_seedCopiedTimer != null) {
                                  _seedCopiedTimer.cancel();
                                }
                                _seedCopiedTimer = new Timer(
                                    const Duration(milliseconds: 800), () {
                                  setState(() {
                                    _seedCopied = false;
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
                                    child: UIUtil.threeLineSeedText(_seed,
                                        textStyle: _seedCopied ? KaliumStyles.TextStyleSeedGreen : KaliumStyles.TextStyleSeed),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(KaliumLocalization.of(context).seedCopied,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: _seedCopied ? KaliumColors.success : Colors.transparent,
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
                        KaliumButton.buildKaliumButton(
                          KaliumButtonType.PRIMARY_OUTLINE,
                          KaliumLocalization.of(context).close,
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

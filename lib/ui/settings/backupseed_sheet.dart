import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/util/clipboardutil.dart';

class KaliumSeedBackupSheet {
  // Seed copied state information
  String _placeholderSeed = '●'*64;
  bool _seedCopied;
  String _seed;
  Timer _seedCopiedTimer;
  bool _seedHidden = true;

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
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            KaliumLocalization.of(context).seed.toUpperCase(),
                            style: KaliumStyles.textStyleHeader(context),
                            maxLines: 1,
                            stepGranularity: 0.1,
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
                                ClipboardUtil.setClipboardClearEvent();
                                setState(() {
                                  _seedCopied = true;
                                });
                                if (_seedCopiedTimer != null) {
                                  _seedCopiedTimer.cancel();
                                }
                                _seedCopiedTimer = new Timer(
                                    const Duration(milliseconds: 1200), () {
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
                                    child: UIUtil.threeLineSeedText(_seedHidden ? _placeholderSeed : _seed,
                                        textStyle: _seedCopied ? KaliumStyles.TextStyleSeedGreen : KaliumStyles.TextStyleSeed),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Text(KaliumLocalization.of(context).seedCopied,
                                        textAlign: TextAlign.center,
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

                    //A row with show/hide seed button
                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
                          KaliumButtonType.PRIMARY,
                          _seedHidden ? KaliumLocalization.of(context).showSeedButton : KaliumLocalization.of(context).hideSeedButton,
                          Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                            if (_seedHidden) {
                              setState(() {
                                _seedHidden = false;
                              });
                            } else {
                              setState(() {
                                _seedHidden = true;
                              }); 
                            }
                          },
                        ),
                      ],
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

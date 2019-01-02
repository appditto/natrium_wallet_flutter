import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumSeedBackupSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
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
                        Container(
                          margin: EdgeInsets.only(top:25),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: threeLineSeedText("AB90FB510F11218B59A5673C14E99CB018EBC9D9BA7D431EA1924267EA65C462"),
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
  }
}

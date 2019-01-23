import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_complete_sheet.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumTransferConfirmSheet {
  mainBottomSheet(BuildContext context) {
    Vault.inst.getSeed().then((result) {
      KaliumSheets.showKaliumHeightNineSheet(
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
                      margin: EdgeInsets.only(top: 30.0, left:70, right: 70),
                      child: AutoSizeText(
                        KaliumLocalization.of(context).transferHeader.toUpperCase(),
                        style: KaliumStyles.textStyleHeader(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        stepGranularity: 0.1,
                      ),
                    ),

                    // A container for the paragraphs
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: smallScreen(context)?35:60),
                                child: Text(
                                  KaliumLocalization.of(context).transferConfirmInfo,
                                  style: KaliumStyles.TextStyleParagraphPrimary,
                                  textAlign: TextAlign.left,
                            )),
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: smallScreen(context)?35:60),
                                child: Text(
                                  KaliumLocalization.of(context).transferConfirmInfoSecond,
                                  style: KaliumStyles.TextStyleParagraph,
                                  textAlign: TextAlign.left,
                            )),
                            Container(
                                margin: EdgeInsets.symmetric(horizontal: smallScreen(context)?35:60),
                                child: Text(
                                  KaliumLocalization.of(context).transferConfirmInfoThird,
                                  style: KaliumStyles.TextStyleParagraph,
                                  textAlign: TextAlign.left,
                            )),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // Send Button
                              KaliumButton.buildKaliumButton(
                                  KaliumButtonType.PRIMARY,
                                  KaliumLocalization.of(context).confirm.toUpperCase(),
                                  Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                                    KaliumTransferCompleteSheet().mainBottomSheet(context);
                              }),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              // Scan QR Code Button
                              KaliumButton.buildKaliumButton(
                                  KaliumButtonType.PRIMARY_OUTLINE,
                                  KaliumLocalization.of(context).cancel.toUpperCase(),
                                  Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                                Navigator.of(context).pop();
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          });
    });
  }
}

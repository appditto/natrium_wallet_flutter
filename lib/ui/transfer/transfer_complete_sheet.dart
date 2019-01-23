import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumTransferCompleteSheet {
  mainBottomSheet(BuildContext context) {
    Vault.inst.getSeed().then((result) {
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
                            KaliumLocalization.of(context).transferHeader.toUpperCase(),
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
                                  KaliumLocalization.of(context).transferComplete,
                                  style: KaliumStyles.TextStyleParagraph,
                            )),
                            Container(
                                margin: EdgeInsets.only(left: 50, right: 50),
                                child: Text(
                                  KaliumLocalization.of(context).transferClose,
                                  style: KaliumStyles.TextStyleParagraph,
                            )),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
                          KaliumButtonType.SUCCESS_OUTLINE,
                          KaliumLocalization.of(context).close.toUpperCase(),
                          Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                            Navigator.of(context).pop();
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

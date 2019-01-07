import 'dart:async';
import 'package:flutter/material.dart';

import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

class KaliumSendConfirmSheet {
  String _amount;
  String _amountRaw;
  String _destination;
  bool _maxSend;

  KaliumSendConfirmSheet(String amount, String destinaton, {bool maxSend}) {
    _amount = amount;
    _amountRaw = NumberUtil.getAmountAsRaw(amount);
    _destination = destinaton;
    _maxSend = maxSend ?? false;
  }

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        animationDurationMs: 100,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(KaliumIcons.close,
                            size: 16, color: KaliumColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),
                  ],
                ),

                Expanded(
                  //A main container that holds the text fields
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "SENDING",
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 60, right: 60),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: KaliumColors.backgroundDarkest,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: "$_amount",
                                style: TextStyle(
                                  color: KaliumColors.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: " BAN",
                                style: TextStyle(
                                  color: KaliumColors.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "TO",
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          margin: EdgeInsets.only(left: 60, right: 60),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(_destination)),
                    ],
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY,
                              'CONFIRM',
                              Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                            Navigator.of(context).push(SendAnimationOverlay());
                            Future.delayed(new Duration(seconds: 5), () {
                              KaliumSendCompleteSheet(_amount, _destination).mainBottomSheet(context);
                            });
                          }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              'CANCEL',
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.of(context).pop();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }
}

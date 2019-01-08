import 'package:flutter/material.dart';

import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';

class KaliumSendCompleteSheet {
  String _amount;
  String _destination;

  KaliumSendCompleteSheet(String amount, String destinaton) {
    _amount = amount;
    _destination = destinaton;
  }

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        animationDurationMs: 100,
        removeUntilHome: true,
        closeOnTap: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top:50),
                      child: Icon(KaliumIcons.success, size: 100, color: KaliumColors.success),
                    ),
                  ],
                ),

                Expanded(
                  //A main container that holds the text fields
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.105, right: MediaQuery.of(context).size.width*0.105),
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
                                  color: KaliumColors.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'NunitoSans',
                                ),
                              ),
                              TextSpan(
                                text: " BAN",
                                style: TextStyle(
                                  color: KaliumColors.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans',
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
                              "SENT TO",
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                color: KaliumColors.success,
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.105, right: MediaQuery.of(context).size.width*0.105),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(_destination, type: ThreeLineAddressTextType.SUCCESS)),
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
                              KaliumButtonType.SUCCESS_OUTLINE,
                              'CLOSE',
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

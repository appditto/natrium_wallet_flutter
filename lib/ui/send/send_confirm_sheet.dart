import 'package:flutter/material.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
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
    showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState)
          {
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
                        child:
                        Icon(KaliumIcons.close, size: 16,
                            color: KaliumColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    //Container for the header and address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "SEND FROM",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: threeLineAddressText(
                                StateContainer
                                    .of(context)
                                    .wallet
                                    .address),
                          ),
                        ],
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

                //A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 70, right: 70),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            "$_amount BAN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: KaliumColors.primary,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          margin: EdgeInsets.only(left: 70, right: 70, top: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: threeLineAddressText(_destination)
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          buildKaliumButton(KaliumButtonType.PRIMARY, 'CONFIRM',
                              Dimens.BUTTON_TOP_DIMENS,
                              onPressed: () {
                                // TODO - Handle send button press
                              }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                              'CANCEL', Dimens.BUTTON_BOTTOM_DIMENS,
                              onPressed: () {
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
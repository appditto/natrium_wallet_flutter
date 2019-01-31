import 'package:flutter/material.dart';

import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';

class KaliumSendCompleteSheet {
  String _amount;
  String _destination;
  String _contactName;

  KaliumSendCompleteSheet(
      String amount, String destinaton, String contactName) {
    _amount = amount;
    _destination = destinaton;
    _contactName = contactName;
  }

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        animationDurationMs: 100,
        removeUntilHome: false,
        closeOnTap: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // The main column that holds everything
            return Column(
              children: <Widget>[
                //A main container that holds the amount, address and "SENT TO" texts
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Success tick (icon)
                      Container(
                        alignment: Alignment(0, 0),
                        margin: EdgeInsets.only(bottom: 25),
                        child: Icon(KaliumIcons.success,
                            size: 100, color: AppColors.success),
                      ),
                      // Container for the Amount Text
                      Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.105,
                            right: MediaQuery.of(context).size.width * 0.105),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDarkest,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        // Amount text
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: "$_amount",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'NunitoSans',
                                ),
                              ),
                              TextSpan(
                                text: " BAN",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Container for the "SENT TO" text
                      Container(
                        margin: EdgeInsets.only(top: 30.0, bottom: 10),
                        child: Column(
                          children: <Widget>[
                            // "SENT TO" text
                            Text(
                              AppLocalization.of(context)
                                  .sentTo
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // The container for the address
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(_destination,
                              type: ThreeLineAddressTextType.SUCCESS,
                              contactName: _contactName)),
                    ],
                  ),
                ),

                // CLOSE Button
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                              AppButtonType.SUCCESS_OUTLINE,
                              AppLocalization.of(context)
                                  .close
                                  .toUpperCase(),
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
